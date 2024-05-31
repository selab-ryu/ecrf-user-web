package ecrf.user.crf.util.data;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.util.Validator;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;

import ecrf.user.model.CRFHistory;

public class HistorySearch {
private Log _log;
	
	public HistorySearch() {
		_log = LogFactoryUtil.getLog(this.getClass().getName());
	}
	
	public Calendar getSearchCal(int year, int month, int day, boolean isStart) {
		Calendar cal = Calendar.getInstance();
		
		cal.set(Calendar.YEAR, year);
		cal.set(Calendar.MONTH, month);
		cal.set(Calendar.DATE, day);
		
		if (isStart) {
			cal.set(Calendar.HOUR_OF_DAY, 0);
			cal.set(Calendar.MINUTE, 0);
			cal.set(Calendar.SECOND, 0);
		} else {
			cal.set(Calendar.HOUR_OF_DAY, 23);
			cal.set(Calendar.MINUTE, 59);
			cal.set(Calendar.SECOND, 59);
		}
		
		return cal;
	}
	
	public ArrayList<CRFHistory> search(ArrayList<CRFHistory> list,
			String subjectId, String subjectName, String crfItemName,
			int actionType, String modifiedUserName,
			Date modifiedDateStart, Date modifiedDateEnd) {
		
		if(Validator.isNotNull(subjectId)) list = searchBySubjectId(list, subjectId);
		if(Validator.isNotNull(subjectName)) list = searchBySubjectName(list, subjectName);
		if(Validator.isNotNull(actionType)) list = searchByActionType(list, actionType);
		if(Validator.isNotNull(modifiedUserName)) list = searchByModifiedUserName(list, modifiedUserName);
		if(Validator.isNotNull(modifiedDateStart)) list = searchByModifiedDate(list, modifiedDateStart, true);
		if(Validator.isNotNull(modifiedDateEnd)) list = searchByModifiedDate(list, modifiedDateEnd, false);
				
		return list;
	}
	
	private ArrayList<CRFHistory> searchBySubjectId(ArrayList<CRFHistory> list, String searchKeyword) {
		ArrayList<CRFHistory> result = new ArrayList<>();
		for(int i=0; i<list.size(); i++) {
			CRFHistory obj = list.get(i);
			String origin = obj.getSerialId();
			if(origin.toLowerCase().contains(searchKeyword.toLowerCase())) {
				//System.out.println(origin);
				result.add(obj);
			}
		}
		return result;
	}
	
	private ArrayList<CRFHistory> searchBySubjectName(ArrayList<CRFHistory> list, String searchKeyword) {
		ArrayList<CRFHistory> result = new ArrayList<>();
		for(int i=0; i<list.size(); i++) {
			CRFHistory obj = list.get(i);
			String origin = obj.getSubjectName();
			if(origin.toLowerCase().contains(searchKeyword.toLowerCase())) {
				//System.out.println(origin);
				result.add(obj);
			}
		}
		return result;
	}
		
	private ArrayList<CRFHistory> searchByActionType(ArrayList<CRFHistory> list, int type) {
		ArrayList<CRFHistory> result = new ArrayList<>();
		for(int i=0; i<list.size(); i++) {
			CRFHistory obj = list.get(i);
			int origin = obj.getActionType();
			if(origin == type) {
				//System.out.println(origin);
				result.add(obj);
			}
		}
		return result;
	}
	
	private ArrayList<CRFHistory> searchByModifiedUserName(ArrayList<CRFHistory> list, String searchKeyword) {
		ArrayList<CRFHistory> result = new ArrayList<>();
		for(int i=0; i<list.size(); i++) {
			CRFHistory obj = list.get(i);
			String origin = obj.getUserName();
			if(origin.toLowerCase().contains(searchKeyword.toLowerCase())) {
				//System.out.println(origin);
				result.add(obj);
			}
		}
		return result;
	}
	
	public ArrayList<CRFHistory> searchByModifiedDate(ArrayList<CRFHistory> list, Date searchDate, boolean isStart) {
		ArrayList<CRFHistory> result = new ArrayList<>();
		for(int i=0; i<list.size(); i++) {
			CRFHistory origin = list.get(i);
			Date originDate = origin.getModifiedDate();
			int compare = originDate.compareTo(searchDate);
			if(isStart) {
				if(compare >= 0) result.add(origin);
			} else {
				if(compare <= 0) result.add(origin);
			}
		}
		return result;
	}
}
