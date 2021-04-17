package fr.lpiot.hubiot.ui.data;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import java.util.ArrayList;

import fr.lpiot.hubiot.R;

public class DataAdapter extends RecyclerView.Adapter<DataViewHolder> {

    //private List
    private ArrayList<String> data;

    public DataAdapter(ArrayList<String> data) {
        this.data = data;
    }

    public DataAdapter(){
        this.data = new ArrayList<>();
    }

    @NonNull
    @Override
    public DataViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        Context context = parent.getContext();
        LayoutInflater inflater = LayoutInflater.from(context);
        View view = inflater.inflate(R.layout.fragment_data_item, parent, false);

        return new DataViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull DataViewHolder holder, int position) {
        holder.updateWithData(this.data.get(position));
    }

    @Override
    public int getItemCount() {
        if (this.data == null) {
            this.data = new ArrayList<>();
        }
        return this.data.size();
    }
}
