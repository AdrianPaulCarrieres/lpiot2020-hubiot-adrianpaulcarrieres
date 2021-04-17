package fr.lpiot.hubiot.ui.presence;

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

public class PresenceFragment extends Fragment {

    //For design
    @BindView(R.id.fragment_presence_recycler_view)
    RecyclerView recyclerView;

    //For data
    private ArrayList<String> users;
    private UserAdapter adapter;
    private PresenceViewModel presenceViewModel;


    public PresenceFragment() {
    }

    public View onCreateView(@NonNull LayoutInflater inflater,
                             ViewGroup container, Bundle savedInstanceState) {

        View root = inflater.inflate(R.layout.fragment_presence, container, false);

        ButterKnife.bind(this, root);

        this.configureRecyclerView();

        presenceViewModel = new ViewModelProvider(getActivity()).get(PresenceViewModel.class);
        presenceViewModel.getData().observe(getViewLifecycleOwner(), new Observer<ArrayList<String>>() {
            @Override
            public void onChanged(ArrayList<String> list) {
                System.out.println("heeeey" + list.toString());
                users.clear();
                users.addAll(list);
                System.out.println("users list in presence fragment is " + users.toString());
                adapter.notifyDataSetChanged();
            }
        });
        return root;
    }

    private void configureRecyclerView() {
        //Hub hub = (Hub) getActivity();
        //this.users = hub.getUsers();

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

    public void addUsers(ArrayList<String> users) {
        this.users.clear();
        this.users.addAll(users);
        adapter.notifyDataSetChanged();
    }
}