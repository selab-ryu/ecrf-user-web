package ecrf.user.crf.util.data;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

import teeth.model.TreatmentHistory;

public class DisplayHistory
{
   public String TreatmentID; //
   public String TreatmnetString;
   public Date Date;
   public String Status;
   
   private int ageYears;
   private int ageMonths;
   private int ageDays;
   
    // TreatmentIDList
    public String getTreatmentID() {
        return TreatmentID;
    }

    public void setTreatmentID(String treatmentID) {
        this.TreatmentID = treatmentID;
    }

    // TreatmnetStringList
    public String getTreatmnetString() {
        return TreatmnetString;
    }

    public void setTreatmnetString(String treatmnetString) {
        this.TreatmnetString = treatmnetString;
    }

    // Date
    public Date getDate() {
        return Date;
    }

    public void setDate(Date date) {
        this.Date = date;
    }

    // Status
    public String getStatus() {
        return Status;
    }

    public void setStatus(String status) {
        this.Status = status;
    }
    
    public int getAgeYears() {
        return ageYears;
    }
    public void setAgeYears(int ageYears) {
        this.ageYears = ageYears;
    }
    public int getAgeMonths() {
        return ageMonths;
    }
    public void setAgeMonths(int ageMonths) {
        this.ageMonths = ageMonths;
    }
    public int getAgeDays() {
        return ageDays;
    }
    public void setAgeDays(int ageDays) {
        this.ageDays = ageDays;
    }
    
    
    // Group by treatementDate
    public static List<DisplayHistory> buildDisplayHistoryList(List<TreatmentHistory> histories, Date birthDate) {
        // Date sorting by using TreeMap
        Map<Long, DisplayHistory> map = new TreeMap<>();

        for (TreatmentHistory h : histories) {
            Date date = h.getTreatmentDate();
            Long ID = h.getTreatmentID();
            DisplayHistory dh = map.get(ID);

            if (dh == null) {
                dh = new DisplayHistory();
                dh.setDate(date);

                // After birth
                Calendar bCal = Calendar.getInstance();
                bCal.setTime(birthDate);
                Calendar dCal = Calendar.getInstance();
                dCal.setTime(date);

                int years  = dCal.get(Calendar.YEAR)  - bCal.get(Calendar.YEAR);
                int months = dCal.get(Calendar.MONTH) - bCal.get(Calendar.MONTH);
                int days   = dCal.get(Calendar.DAY_OF_MONTH) - bCal.get(Calendar.DAY_OF_MONTH);

                // days modification
                if (days < 0) {
                    months--;
                    Calendar tmp = (Calendar) dCal.clone();
                    tmp.add(Calendar.MONTH, -1);
                    days += tmp.getActualMaximum(Calendar.DAY_OF_MONTH);
                }
                // months modification
                if (months < 0) {
                    years--;
                    months += 12;
                }

                dh.setAgeYears(years);
                dh.setAgeMonths(months);
                dh.setAgeDays(days);

                // init others
                dh.setTreatmentID("");
                dh.setTreatmnetString("");
                dh.setStatus("");
                map.put(ID, dh);
            }
            
            dh.setTreatmentID(String.valueOf(h.getTreatmentID()));

            dh.setTreatmnetString(h.getTreatment());

            dh.setStatus(h.getState());
            
        }

        return new ArrayList<>(map.values());
    }
    
    Log _log = LogFactoryUtil.getLog(DisplayHistory.class);
}