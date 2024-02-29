package ecrf.user.subject.util;

import com.liferay.petra.string.StringPool;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;

import ecrf.user.model.Subject;

public class SubjectSearchUtil {
	public static Calendar getSearchCal(int year, int month, int day, boolean isStart) {
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
	
	public static ArrayList<Subject> search(ArrayList<Subject> subjectList,
			String subjectIdStr, String subjectName, int subjectSex,
			Date birthStart, Date birthEnd
			)
	{
		if(!subjectIdStr.equals(StringPool.BLANK)) subjectList = searchBySubjectId(subjectList, subjectIdStr);
		if(!subjectName.equals(StringPool.BLANK)) subjectList = searchBySubjectName(subjectList, subjectName);
		if(subjectSex != -1) subjectList = searchBySubjectSex(subjectList, subjectSex);
		if(birthStart != null) subjectList = searchByBirth(subjectList, birthStart, true);
		if(birthEnd != null) subjectList = searchByBirth(subjectList, birthEnd, false);
		
		return subjectList;
	}
	
	private static ArrayList<Subject> searchBySubjectId(ArrayList<Subject> subjectList, String subjectIdKeyword) {
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
	
	public static ArrayList<Subject> searchBySubjectName(ArrayList<Subject> subjectList, String nameKeyword) {
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
	
	public static ArrayList<Subject> searchBySubjectSex(ArrayList<Subject> subjectList, int subjectSexKeyword) {
		ArrayList<Subject> result = new ArrayList<>();
		for(int i=0; i<subjectList.size(); i++) {
			Subject subject = subjectList.get(i);
			int gender = subject.getGender();
			
			if(gender == subjectSexKeyword) {
				System.out.println(gender);
				result.add(subject);
			}
		}
		return result;
	}
	
	public static ArrayList<Subject> searchByBirth(ArrayList<Subject> subjectList, Date searchDate, boolean isStart) {
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
