package fr.lpiot.hubiot;

import android.net.Uri;
import android.os.Bundle;
import android.view.Menu;

import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import androidx.drawerlayout.widget.DrawerLayout;
import androidx.lifecycle.ViewModelProvider;
import androidx.navigation.NavController;
import androidx.navigation.Navigation;
import androidx.navigation.ui.AppBarConfiguration;
import androidx.navigation.ui.NavigationUI;

import com.fasterxml.jackson.databind.JsonNode;
import com.google.android.material.navigation.NavigationView;

import org.phoenixframework.channels.Channel;
import org.phoenixframework.channels.Socket;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;

import fr.lpiot.hubiot.ui.data.DataViewModel;
import fr.lpiot.hubiot.ui.presence.PresenceViewModel;

public class Hub extends AppCompatActivity {

    private AppBarConfiguration mAppBarConfiguration;

    private final ArrayList<String> users = new ArrayList<>();
    private final ArrayList<String> data = new ArrayList<>();

    private PresenceViewModel presenceViewModel;
    private DataViewModel dataViewModel;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_hub);
        Toolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        DrawerLayout drawer = findViewById(R.id.drawer_layout);
        NavigationView navigationView = findViewById(R.id.nav_view);
        // Passing each menu ID as a set of Ids because each
        // menu should be considered as top level destinations.
        mAppBarConfiguration = new AppBarConfiguration.Builder(
                R.id.nav_home, R.id.nav_presence, R.id.nav_data)
                .setDrawerLayout(drawer)
                .build();
        NavController navController = Navigation.findNavController(this, R.id.nav_host_fragment);
        NavigationUI.setupActionBarWithNavController(this, navController, mAppBarConfiguration);
        NavigationUI.setupWithNavController(navigationView, navController);

        presenceViewModel = new ViewModelProvider(this).get(PresenceViewModel.class);
        dataViewModel = new ViewModelProvider(this).get(DataViewModel.class);

        Uri.Builder url = Uri.parse("ws://192.168.1.70:4000/socket/websocket").buildUpon();

        try {

            Socket socket = new Socket(url.build().toString());
            socket.connect();

            Channel channel = socket.chan("capteur:location_1", null);

            channel.join()
                    .receive("ignore", envelope -> System.out.println("IGNORE"))
                    .receive("ok", envelope -> {
                        this.users.clear();
                        for (JsonNode jsonNode : envelope.getPayload().get("response").get("users")) {
                            String user = jsonNode.asText();
                            this.users.add(user);
                        }
                        System.out.println(presenceViewModel == null);
                        presenceViewModel.getData().postValue(users);
                    });

            channel.on("user_joined", envelope -> {
                String user = envelope.getPayload().get("name").asText();
                System.out.println("name " + user);

                this.users.add(user);
                runOnUiThread(() -> {
                    presenceViewModel.getData().setValue(users);
                    System.out.println(presenceViewModel.getData().getValue().toString());
                });
            });

            channel.on("user_left", envelope -> {
                String user = envelope.getPayload().get("name").asText();
                System.out.println("name " + user);

                this.users.remove(user);

                runOnUiThread(() -> {
                    presenceViewModel.getData().setValue(users);
                    System.out.println(presenceViewModel.getData().getValue().toString());
                });
            });

            channel.on("new_data", envelope -> {
                String newData = envelope.getPayload().get("data").get("inserted_at").asText() + " - " + envelope.getPayload().get("data").get("value").asText();
                System.out.println(envelope);

                Collections.sort(this.data);

                this.data.add(newData);
                int i = 0;
                while (this.data.size() > 10) {
                    this.data.remove(i++);
                }

                Collections.sort(this.data, Collections.reverseOrder());

                runOnUiThread(() -> {
                    dataViewModel.getData().setValue(data);
                    System.out.println(dataViewModel.getData().getValue().toString());
                });
            });

        } catch (IOException e) {
            System.out.println("error");
        }


    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.hub, menu);
        return true;
    }

    @Override
    public boolean onSupportNavigateUp() {
        NavController navController = Navigation.findNavController(this, R.id.nav_host_fragment);
        return NavigationUI.navigateUp(navController, mAppBarConfiguration)
                || super.onSupportNavigateUp();
    }
}