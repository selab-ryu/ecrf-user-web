package ecrf.user.project.util;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.util.Validator;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;

import javax.portlet.RenderRequest;

import ecrf.user.constants.type.ExperimentalGroupType;
import ecrf.user.constants.type.Gender;
import ecrf.user.model.ExperimentalGroup;
import ecrf.user.model.Researcher;

public class ExpGroupSearchUtil {
	private Log _log = LogFactoryUtil.getLog(ExpGroupSearchUtil.class);
	
	ArrayList<ExperimentalGroup> initList;
	ArrayList<ExperimentalGroup> resultList;

	RenderRequest request;
	
	public ExpGroupSearchUtil(ArrayList<ExperimentalGroup> list) {
		this.initList = list;
		this.resultList = list;
	}
	
	public void setList(ArrayList<ExperimentalGroup> list) {
		this.initList = list;
		this.resultList = list;
	}
	
	public void setRequest(RenderRequest request) {
		this.request = request;
	}
	
	public void refresh() {
		this.resultList = this.initList;
	}
	
	public ArrayList<ExperimentalGroup> search(
			String name, String abbr, ExperimentalGroupType type)
	{	
		if(Validator.isNotNull(name)) resultList = searchByName(name);
		if(Validator.isNotNull(abbr)) resultList = searchByAbbreviation(abbr);
		if(Validator.isNotNull(type)) resultList = searchByType(type.getNum());
		
		return this.resultList;
	}
	
	private ArrayList<ExperimentalGroup> searchByName(String nameKeyword) {
		ArrayList<ExperimentalGroup> result = new ArrayList<>();
		for(int i=0; i<resultList.size(); i++) {
			ExperimentalGroup expGroup = resultList.get(i);
			String name = expGroup.getName();
			if(name.toLowerCase().contains(nameKeyword.toLowerCase())) {
				result.add(expGroup);
			}
		}
		
		return result;
	}
	
	private ArrayList<ExperimentalGroup> searchByAbbreviation(String abbrKeyword) {
		ArrayList<ExperimentalGroup> result = new ArrayList<>();
		for(int i=0; i<resultList.size(); i++) {
			ExperimentalGroup expGroup = resultList.get(i);
			String abbr = expGroup.getAbbreviation();
			if(abbr.toLowerCase().contains(abbrKeyword.toLowerCase())) {
				result.add(expGroup);
			}
		}
		return result;
	}
	
	private ArrayList<ExperimentalGroup> searchByType(int typeKeyword) {
		ArrayList<ExperimentalGroup> result = new ArrayList<>();
		for(int i=0; i<resultList.size(); i++) {
			ExperimentalGroup expGroup = resultList.get(i);
			int type = expGroup.getType();
			if(type == typeKeyword) {
				result.add(expGroup);
			}
		}
		return result;
	}
}
