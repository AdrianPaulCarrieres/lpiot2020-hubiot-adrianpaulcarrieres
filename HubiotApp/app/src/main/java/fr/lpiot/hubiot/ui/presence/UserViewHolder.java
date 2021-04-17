package fr.lpiot.hubiot.ui.presence;

import android.view.View;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import butterknife.BindView;
import butterknife.ButterKnife;
import fr.lpiot.hubiot.R;

public class UserViewHolder extends RecyclerView.ViewHolder {

    @BindView(R.id.fragment_presence_item_title)
    TextView textView;

    public UserViewHolder(@NonNull View itemView) {
        super(itemView);
        ButterKnife.bind(this, itemView);
    }

    public void updateWithUser(String user) {
        this.textView.setText(user);
    }
}
