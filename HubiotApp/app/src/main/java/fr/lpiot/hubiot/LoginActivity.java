package fr.lpiot.hubiot;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

public class LoginActivity extends AppCompatActivity {

    //View
    protected TextView textViewIdentifiant;
    protected TextView textViewMotDePasse;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);

        textViewIdentifiant = findViewById(R.id.identifiant);
        textViewMotDePasse = findViewById(R.id.mdp);
    }

    private void afficherToast(String message){
        Toast t = Toast.makeText(this, message, Toast.LENGTH_SHORT);
        t.show();
        Log.i("login", "toasted message : " + message);
    }

    public void buttonLoginClick(View v){
        String email = textViewIdentifiant.getText().toString();
        String password = textViewMotDePasse.getText().toString();

        if(!email.equals("") && !password.equals("")) {
            afficherToast("Tous les champs sont requis");
        } else {
            naviguerVersMenu(email, password);
        }
    }

    private void naviguerVersMenu(String email, String password){
        //Passer au prochain écran -> pour le test on va faire la création
        Intent intent = new Intent(this, Qr.class);
        intent.putExtra("email", email);
        intent.putExtra("password", password);
        startActivity(intent);
    }
}