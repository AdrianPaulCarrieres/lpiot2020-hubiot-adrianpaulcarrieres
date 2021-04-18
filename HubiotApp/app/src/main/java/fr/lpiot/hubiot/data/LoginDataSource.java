package fr.lpiot.hubiot.data;

import java.io.IOException;

import fr.lpiot.hubiot.data.model.ApiResponse;
import fr.lpiot.hubiot.data.model.LoggedInUser;
import retrofit2.Call;
import retrofit2.Response;

/**
 * Class that handles authentication w/ login credentials and retrieves user information.
 */
public class LoginDataSource {

    public Result<LoggedInUser> login(String email, String password) {

        try {

            GetDataService service = RetrofitClientInstance.getRetrofitInstance().create(GetDataService.class);

            Call<ApiResponse> call = service.login(email, password);

            Response<ApiResponse> response = call.execute();

            if (response.isSuccessful()){
                String token = response.body().getToken();

                LoggedInUser user = new LoggedInUser(token);

                return new Result.Success<>(user);
            } else {
                return new Result.Error(new IOException("Error logging in"));
            }

        } catch (Exception e) {
            return new Result.Error(new IOException("Error logging in", e));
        }
    }

    public void logout() {
        // revoke authentication
    }
}