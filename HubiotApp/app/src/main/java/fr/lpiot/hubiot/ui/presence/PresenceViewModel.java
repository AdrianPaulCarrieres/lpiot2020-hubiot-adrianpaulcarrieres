package fr.lpiot.hubiot.ui.presence;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

public class PresenceViewModel extends ViewModel {

    private MutableLiveData<String> mText;

    public PresenceViewModel() {
        mText = new MutableLiveData<>();
        mText.setValue("This is gallery fragment");
    }

    public LiveData<String> getText() {
        return mText;
    }
}