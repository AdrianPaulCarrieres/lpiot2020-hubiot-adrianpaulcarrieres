package fr.lpiot.hubiot.ui.data;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;

import fr.lpiot.hubiot.R;

public class DataFragment extends Fragment {

    private DataViewModel dataViewModel;

    private String data;

    public View onCreateView(@NonNull LayoutInflater inflater,
                             ViewGroup container, Bundle savedInstanceState) {
        dataViewModel =
                new ViewModelProvider(this).get(DataViewModel.class);
        View root = inflater.inflate(R.layout.fragment_data, container, false);

        return root;
    }

    public String getData() {
        return data;
    }

    public void setData(String data) {
        this.data = data;
    }
}