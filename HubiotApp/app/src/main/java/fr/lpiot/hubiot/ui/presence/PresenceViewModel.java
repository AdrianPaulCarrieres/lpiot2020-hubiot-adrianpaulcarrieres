package fr.lpiot.hubiot.ui.presence;

import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import java.util.ArrayList;

public class PresenceViewModel extends ViewModel {

    private MutableLiveData<ArrayList<String>> data;

    public PresenceViewModel(MutableLiveData<ArrayList<String>> data) {
        this.data = data;
    }

    public PresenceViewModel() {
        this.data = new MutableLiveData<>();
    }

    public MutableLiveData<ArrayList<String>> getData() {
        if (this.data == null) {
            this.data = new MutableLiveData<>();
        }
        return data;
    }

    public void setData(MutableLiveData<ArrayList<String>> data) {
        this.data = data;
    }
}