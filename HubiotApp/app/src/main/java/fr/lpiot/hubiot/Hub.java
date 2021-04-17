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

import com.google.android.material.navigation.NavigationView;

import org.phoenixframework.channels.Channel;
import org.phoenixframework.channels.Socket;

import java.io.IOException;
import java.util.ArrayList;

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
                R.id.nav_home, R.id.nav_gallery, R.id.nav_slideshow)
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
                    .receive("ok", envelope -> System.out.println("JOINED with " + envelope.toString()));

            channel.on("new_user", envelope -> {
                PresenceFragment presenceFragment = (PresenceFragment) getSupportFragmentManager().findFragmentById(R.id.fragment_presence);
                String user = envelope.getPayload().get("name").asText();
                System.out.println("name " + user);

                this.users.add(user);

                if(presenceFragment != null) {
                    presenceFragment.addUser(envelope.getPayload().get("name").asText());
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