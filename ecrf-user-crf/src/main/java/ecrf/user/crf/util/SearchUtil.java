package ecrf.user.crf.util;

import com.liferay.petra.string.StringPool;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.Locale;

import ecrf.user.constants.CRFStatus;
import ecrf.user.model.CRF;
import ecrf.user.model.Subject;
import ecrf.user.service.CRFLocalServiceUtil;

public class SearchUtil {
	private Log _log = LogFactoryUtil.getLog(SearchUtil.class);
	
	ArrayList<CRF> initList;
	ArrayList<CRF> list;
	
	Locale locale;
	
	public SearchUtil(ArrayList<CRF> list) {
		this.initList = list;
		this.list = list;
	}
	
	public SearchUtil(ArrayList<CRF> list, Locale locale) {
		this.initList = list;
		this.list = list;
		this.locale = locale;
	}
	
	
	public void setList(ArrayList<CRF> list) {
		this.initList = list;
		this.list = list;
	}
	
	public void setLocale(Locale locale) {
		this.locale = locale;
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
	
	public ArrayList<CRF> search(
			String title, CRFStatus status, 
			Date applyDateStart, Date applyDateEnd)
	{		
		if(!title.equals(StringPool.BLANK)) list = searchByTitle(title);
		if(status != null) list = searchByStatus(status);
		if(applyDateStart != null) list = searchByApplyDate(applyDateStart, true);
		if(applyDateEnd != null) list = searchByApplyDate(applyDateEnd, false);
		
		return this.list;
	}
	
	private ArrayList<CRF> searchByTitle(String titleKeyword) {
		ArrayList<CRF> result = new ArrayList<>();
		for(int i=0; i<list.size(); i++) {
			CRF crf = list.get(i);
			String title = CRFLocalServiceUtil.getTitle(crf.getCrfId(), locale);
			if(title.toLowerCase().contains(titleKeyword.toLowerCase())) {
				//_log.info(title);
				result.add(crf);
			}
		}
		return result;
	}
	
	public ArrayList<CRF> searchByStatus(CRFStatus statusKeyword) {
		ArrayList<CRF> result = new ArrayList<>();
		for(int i=0; i<list.size(); i++) {
			CRF crf = list.get(i);
			CRFStatus status = CRFStatus.valueOf(crf.getCrfStatus());
			if(status.getNum() == statusKeyword.getNum()) {
				result.add(crf);
			}
		}
		return result;
	}
		
	public ArrayList<CRF> searchByApplyDate(Date searchDate, boolean isStart) {
		ArrayList<CRF> result = new ArrayList<>();
		for(int i=0; i<list.size(); i++) {
			CRF crf = list.get(i);
			Date date = crf.getApplyDate();
			int compare = date.compareTo(searchDate);
			if(isStart) {
				if(compare >= 0) result.add(crf);
			} else {
				if(compare <= 0) result.add(crf);
			}
		}
		return result;
	}

}
