package fr.lpiot.hubiot.data;

import fr.lpiot.hubiot.data.model.ApiResponse;
import retrofit2.Call;
import retrofit2.http.POST;
import retrofit2.http.Query;

public interface GetDataService {
    @POST("login")
    Call<ApiResponse> login(@Query("email") String email, @Query("password") String password);
}
