package fr.lpiot.hubiot;

import android.net.Uri;
import android.os.Bundle;
import android.view.Menu;

import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import androidx.drawerlayout.widget.DrawerLayout;
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
import java.util.Iterator;

import fr.lpiot.hubiot.ui.presence.PresenceFragment;

public class Hub extends AppCompatActivity {

    private AppBarConfiguration mAppBarConfiguration;

    private Socket socket;
    private Channel channel;

    private ArrayList<String> users = new ArrayList<>();

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

        Uri.Builder url = Uri.parse( "ws://192.168.1.70:4000/socket/websocket" ).buildUpon();

        try{

            socket = new Socket(url.build().toString());
            socket.connect();

            channel = socket.chan("capteur:location_1", null);

            channel.join()
                    .receive("ignore", envelope -> System.out.println("IGNORE"))
                    .receive("ok", envelope -> {
                        this.users.clear();
                        for (Iterator<JsonNode> it = envelope.getPayload().get("response").get("users").iterator(); it.hasNext(); ) {
                            String user = it.next().asText();
                            this.users.add(user);
                        }
                        PresenceFragment presenceFragment = (PresenceFragment) getSupportFragmentManager().findFragmentById(R.id.fragment_presence);
                        if(presenceFragment != null) {
                            presenceFragment.addUsers(this.users);
                        }
                    });

            channel.on("user_joined", envelope -> {
                PresenceFragment presenceFragment = (PresenceFragment) getSupportFragmentManager().findFragmentById(R.id.fragment_presence);
                String user = envelope.getPayload().get("name").asText();
                System.out.println("name " + user);

                this.users.add(user);

                if(presenceFragment != null) {
                    presenceFragment.addUser(user);
                }
            });

            channel.on("user_left", envelope -> {
                PresenceFragment presenceFragment = (PresenceFragment) getSupportFragmentManager().findFragmentById(R.id.fragment_presence);
                String user = envelope.getPayload().get("name").asText();
                System.out.println("name " + user);

                this.users.remove(user);

                if(presenceFragment != null) {
                    presenceFragment.removeUser(user);
                }
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

    public ArrayList<String> getUsers() {
        return users;
    }
}