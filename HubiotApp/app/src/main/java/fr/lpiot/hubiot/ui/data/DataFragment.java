package fr.lpiot.hubiot.ui.data;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import java.util.ArrayList;

import butterknife.BindView;
import butterknife.ButterKnife;
import fr.lpiot.hubiot.R;

public class DataFragment extends Fragment {

    //For design
    @BindView(R.id.fragment_data_recycler_view)
    RecyclerView recyclerView;

    //for data
    private ArrayList<String> data;
    private DataAdapter adapter;
    private DataViewModel dataViewModel;

    public DataFragment() {

    }

    public View onCreateView(@NonNull LayoutInflater inflater,
                             ViewGroup container, Bundle savedInstanceState) {
        View root = inflater.inflate(R.layout.fragment_data, container, false);

        ButterKnife.bind(this, root);
        this.configureRecyclerView();

        dataViewModel =
                new ViewModelProvider(getActivity()).get(DataViewModel.class);
        dataViewModel.getData().observe(getViewLifecycleOwner(), new Observer<ArrayList<String>>() {
            @Override
            public void onChanged(ArrayList<String> list) {
                data.clear();
                data.addAll(list);
                adapter.notifyDataSetChanged();
            }
        });

        return root;
    }

    private void configureRecyclerView(){
        this.data = new ArrayList<>();

        this.adapter = new DataAdapter(this.data);

        this.recyclerView.setAdapter(this.adapter);

        this.recyclerView.setLayoutManager(new LinearLayoutManager(getActivity()));
    }

}