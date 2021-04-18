package fr.lpiot.hubiot.data.model;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

public class ApiResponse {

    @SerializedName("response_code")
    @Expose
    private int response_code;
    @SerializedName("token")
    @Expose
    private String token;

    public ApiResponse(int response_code, String token) {
        this.response_code = response_code;
        this.token = token;
    }

    public int getResponse_code() {
        return response_code;
    }

    public void setResponse_code(int response_code) {
        this.response_code = response_code;
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    @Override
    public String toString() {
        return "ApiResponse{" +
                "response_code=" + response_code +
                ", token='" + token + '\'' +
                '}';
    }
}
