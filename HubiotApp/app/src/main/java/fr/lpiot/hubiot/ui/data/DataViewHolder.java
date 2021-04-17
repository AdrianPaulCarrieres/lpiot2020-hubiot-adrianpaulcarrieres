package fr.lpiot.hubiot.ui.data;

import android.view.View;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import butterknife.BindView;
import butterknife.ButterKnife;
import fr.lpiot.hubiot.R;

public class DataViewHolder extends RecyclerView.ViewHolder {

    @BindView(R.id.fragment_data_item_title)
    TextView textView;

    public DataViewHolder(@NonNull View itemView) {
        super(itemView);
        ButterKnife.bind(this, itemView);
    }

    public void updateWithData(String data) {
        this.textView.setText(data);
    }
}
