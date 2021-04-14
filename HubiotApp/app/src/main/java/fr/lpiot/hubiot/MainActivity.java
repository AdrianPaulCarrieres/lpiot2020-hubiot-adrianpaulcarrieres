package fr.lpiot.hubiot;

import android.net.Uri;
import android.os.Bundle;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

import org.phoenixframework.channels.Channel;
import org.phoenixframework.channels.Envelope;
import org.phoenixframework.channels.IMessageCallback;
import org.phoenixframework.channels.Socket;

import java.io.IOException;


public class MainActivity extends AppCompatActivity {

    private Socket socket;
    private Channel channel;

    private TextView label;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        label = findViewById(R.id.label);

        Uri.Builder url = Uri.parse( "ws://192.168.43.183:4000/socket/websocket" ).buildUpon();


        try{

            socket = new Socket(url.build().toString());
            socket.connect();

            channel = socket.chan("room:capteur", null);

            channel.join()
                    .receive("ignore", envelope -> System.out.println("IGNORE"))
                    .receive("ok", envelope -> System.out.println("JOINED with " + envelope.toString()));

            channel.on("new_data", new IMessageCallback() {
                @Override
                public void onMessage(Envelope envelope) {
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            System.out.println(envelope.toString());
                            label.setText(envelope.toString());
                        }
                    });
                }
            });

            } catch (IOException e) {
            System.out.println("error");
        }
    }
}