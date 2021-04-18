package fr.lpiot.hubiot.data.model;

/**
 * Data class that captures user information for logged in users retrieved from LoginRepository
 */
public class LoggedInUser {

    private String token;

    @Override
    public String toString() {
        return "LoggedInUser{" +
                "token='" + token + '\'' +
                '}';
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public LoggedInUser(String token) {
        this.token = token;
    }
}