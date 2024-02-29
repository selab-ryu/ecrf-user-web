package ecrf.user.crf.data.util;

import com.liferay.petra.string.StringPool;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;

import ecrf.user.model.Subject;

public class SearchUtil {
	private Log _log;

	public SearchUtil() {
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
	
	public ArrayList<Subject> search(ArrayList<Subject> subjectList,
			String subjectIdStr, String subjectName, int subjectGender,
			Date birthStart, Date birthEnd)
	{
		if(subjectList.size() == 0) return subjectList;
		if(!subjectIdStr.equals(StringPool.BLANK)) subjectList = searchBySubjectId(subjectList, subjectIdStr);
		if(!subjectName.equals(StringPool.BLANK)) subjectList = searchBySubjectName(subjectList, subjectName);
		if(subjectGender != -1) subjectList = searchBySubjectGender(subjectList, subjectGender);
		if(birthStart != null) subjectList = searchByBirth(subjectList, birthStart, true);
		if(birthEnd != null) subjectList = searchByBirth(subjectList, birthEnd, false);
		
		return subjectList;
	}
	
	private ArrayList<Subject> searchBySubjectId(ArrayList<Subject> subjectList, String subjectIdKeyword) {
		ArrayList<Subject> result = new ArrayList<>();
		for(int i=0; i<subjectList.size(); i++) {
			Subject subejct = subjectList.get(i);
			String subjectIdStr = subejct.getSerialId();
			if(subjectIdStr.toLowerCase().contains(subjectIdKeyword.toLowerCase())) {
				System.out.println(subjectIdStr);
				result.add(subejct);
			}
		}
		return result;
	}
	
	public ArrayList<Subject> searchBySubjectName(ArrayList<Subject> subjectList, String nameKeyword) {
		ArrayList<Subject> result = new ArrayList<>();
		for(int i=0; i<subjectList.size(); i++) {
			Subject subject = subjectList.get(i);
			String name = subject.getName();
			if(name.toLowerCase().contains(nameKeyword.toLowerCase())) {
				result.add(subject);
			}
		}
		return result;
	}
	
	public ArrayList<Subject> searchBySubjectGender(ArrayList<Subject> subjectList, int subjectGenderKeyword) {
		ArrayList<Subject> result = new ArrayList<>();
		for(int i=0; i<subjectList.size(); i++) {
			Subject subject = subjectList.get(i);
			int gender = subject.getGender();
			
			if(gender == subjectGenderKeyword) {
				System.out.println(gender);
				result.add(subject);
			}
		}
		return result;
	}
	
	public ArrayList<Subject> searchByBirth(ArrayList<Subject> subjectList, Date searchDate, boolean isStart) {
		ArrayList<Subject> result = new ArrayList<>();
		for(int i=0; i<subjectList.size(); i++) {
			Subject subject = subjectList.get(i);
			Date birth = subject.getBirth();
			int compare = birth.compareTo(searchDate);
			if(isStart) {
				if(compare >= 0) result.add(subject);
			} else {
				if(compare <= 0) result.add(subject);
			}
		}
		return result;
	}

}
