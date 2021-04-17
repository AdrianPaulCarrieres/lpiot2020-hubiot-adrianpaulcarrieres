package fr.lpiot.hubiot.ui.presence;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import java.util.List;

import fr.lpiot.hubiot.R;

public class UserAdapter extends RecyclerView.Adapter<UserViewHolder> {

    //For DATA
    private List<String> users;

    //Constructor
    public UserAdapter(List<String> users) {
        this.users = users;
    }

    @NonNull
    @Override
    public UserViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        // CREATE VIEW HOLDER AND INFLATING ITS XML LAYOUT
        Context context = parent.getContext();
        LayoutInflater inflater = LayoutInflater.from(context);
        View view = inflater.inflate(R.layout.fragment_presence_item, parent, false);

        return new UserViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull UserViewHolder holder, int position) {
        holder.updateWithUser(this.users.get(position));
    }

    @Override
    public int getItemCount() {
        return this.users.size();
    }
}
