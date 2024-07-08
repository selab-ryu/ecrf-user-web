package ecrf.user.researcher.util;

import com.liferay.portal.kernel.exception.PortalException;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.model.User;
import com.liferay.portal.kernel.service.UserLocalServiceUtil;
import com.liferay.portal.kernel.servlet.SessionErrors;
import com.liferay.portal.kernel.util.Validator;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.Locale;

import javax.portlet.RenderRequest;

import ecrf.user.constants.type.Gender;
import ecrf.user.model.Researcher;

public class SearchUtil {
	private Log _log = LogFactoryUtil.getLog(SearchUtil.class);
	
	ArrayList<Researcher> initList;
	ArrayList<Researcher> list;
	
	Locale locale;
	RenderRequest request;
	
	public SearchUtil(ArrayList<Researcher> list) {
		this.initList = list;
		this.list = list;
	}
	
	public SearchUtil(ArrayList<Researcher> list, Locale locale) {
		this.initList = list;
		this.list = list;
		this.locale = locale;
	}
	
	
	public void setList(ArrayList<Researcher> list) {
		this.initList = list;
		this.list = list;
	}
	
	public void setLocale(Locale locale) {
		this.locale = locale;
	}
	
	public void setRequest(RenderRequest request) {
		this.request = request;
	}
	
	public void refresh() {
		this.list = this.initList;
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
	
	public ArrayList<Researcher> search(
			String email, String screenName, String name,
			Date birthStart, Date birthEnd, Gender gender)
	{	
		if(Validator.isNotNull(email)) list = searchByEmail(email);
		if(Validator.isNotNull(screenName)) list = searchByScreenName(screenName);
		if(Validator.isNotNull(name)) list = searchByName(name);
		if(Validator.isNotNull(gender)) list = searchByGender(gender.getNum());
		if(Validator.isNotNull(birthStart)) list = searchByBirth(birthStart, true);
		if(Validator.isNotNull(birthEnd)) list = searchByBirth(birthEnd, false);
		
		return this.list;
	}
	
	private ArrayList<Researcher> searchByEmail(String emailKeyword) {
		ArrayList<Researcher> result = new ArrayList<>();
		for(int i=0; i<list.size(); i++) {
			Researcher researcher = list.get(i);
			String email = researcher.getEmail();
			if(email.toLowerCase().contains(emailKeyword.toLowerCase())) {
				result.add(researcher);
			}
		}
		return result;
	}
	
	private ArrayList<Researcher> searchByScreenName(String screenNameKeyword) {
		ArrayList<Researcher> result = new ArrayList<>();
		for(int i=0; i<list.size(); i++) {
			Researcher researcher = list.get(i);
			long userId = researcher.getUserId();
			if(userId > 0) {
				User user;
				try {
					user = UserLocalServiceUtil.getUser(userId);
					String screenName = user.getScreenName();
					if(screenName.toLowerCase().contains(screenNameKeyword.toLowerCase())) {
						result.add(researcher);
					}
				} catch (PortalException e) {
					_log.error("user id " + userId + " doesn't exist");
					if(Validator.isNotNull(request)) SessionErrors.add(request, e.getClass(), e);
				}
			}
		}
		return result;
	}
	
	private ArrayList<Researcher> searchByName(String nameKeyword) {
		ArrayList<Researcher> result = new ArrayList<>();
		for(int i=0; i<list.size(); i++) {
			Researcher researcher = list.get(i);
			long userId = researcher.getUserId();
			if(userId > 0) {
				User user;
				try {
					user = UserLocalServiceUtil.getUser(userId);
					String screenName = user.getFullName();
					if(screenName.trim().toLowerCase().contains(nameKeyword.toLowerCase())) {
						result.add(researcher);
					}
				} catch (PortalException e) {
					_log.error("user id " + userId + " doesn't exist");
					if(Validator.isNotNull(request)) SessionErrors.add(request, e.getClass(), e);
				}
			}
		}
		return result;
	}
	
	public ArrayList<Researcher> searchByGender(int genderKeyword) {
		ArrayList<Researcher> result = new ArrayList<>();
		for(int i=0; i<list.size(); i++) {
			Researcher researcher = list.get(i);
			int gender = researcher.getGender();
			if(gender == genderKeyword) {
				result.add(researcher);
			}
		}
		return result;
	}
		
	public ArrayList<Researcher> searchByBirth(Date searchDate, boolean isStart) {
		ArrayList<Researcher> result = new ArrayList<>();
		for(int i=0; i<list.size(); i++) {
			Researcher Researcher = list.get(i);
			Date date = Researcher.getBirth();
			int compare = date.compareTo(searchDate);
			if(isStart) {
				if(compare >= 0) result.add(Researcher);
			} else {
				if(compare <= 0) result.add(Researcher);
			}
		}
		return result;
	}

}
