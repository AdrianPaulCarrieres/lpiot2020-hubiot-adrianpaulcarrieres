package fr.lpiot.hubiot.ui.presence;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import java.util.ArrayList;
import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;
import fr.lpiot.hubiot.R;

public class PresenceFragment extends Fragment {

    //For design
    @BindView(R.id.fragment_presence_recycler_view)
    RecyclerView recyclerView;

    //For data
    private List<String> users;
    private UserAdapter adapter;

    public PresenceFragment() {}

    public View onCreateView(@NonNull LayoutInflater inflater,
                             ViewGroup container, Bundle savedInstanceState) {

        View root = inflater.inflate(R.layout.fragment_presence, container, false);

        ButterKnife.bind(this, root);
        this.configureRecyclerView();

        return root;
    }

    private void configureRecyclerView(){
        this.users = new ArrayList<>();

        this.adapter = new UserAdapter(this.users);

        this.recyclerView.setAdapter(this.adapter);

        this.recyclerView.setLayoutManager(new LinearLayoutManager(getActivity()));
    }

    public void addUser(String user) {
        this.users.add(user);
        adapter.notifyDataSetChanged();
    }

    public void removeUser(String user) {
        this.users.remove(user);
        adapter.notifyDataSetChanged();
    }
}