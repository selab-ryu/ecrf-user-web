package ecrf.user.dashboard.portlet;

import com.liferay.portal.kernel.json.JSONArray;
import com.liferay.portal.kernel.json.JSONFactoryUtil;
import com.liferay.portal.kernel.json.JSONObject;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCPortlet;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.util.Validator;
import com.liferay.portal.kernel.util.WebKeys;
import com.sx.icecap.service.DataTypeLocalService;
import com.sx.icecap.service.StructuredDataLocalService;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.List;

import javax.portlet.Portlet;
import javax.portlet.PortletException;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserJspPaths;
import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.model.CRF;
import ecrf.user.model.LinkCRF;
import ecrf.user.service.CRFLocalService;
import ecrf.user.service.CRFSubjectLocalService;
import ecrf.user.service.LinkCRFLocalService;
import ecrf.user.service.SubjectLocalService;

/**
 * @author Ryu
 */
@Component(
	immediate = true,
	property = {
		"javax.portlet.version=3.0",	// for using MutableRenderParameters
		"com.liferay.portlet.display-category=category.ecrf-user",
		"com.liferay.portlet.header-portlet-css=/css/main.css",
		"com.liferay.portlet.instanceable=false",
		"javax.portlet.display-name=Dashboard",
		"javax.portlet.init-param.template-path=/",
		"javax.portlet.init-param.view-template=" + ECRFUserJspPaths.JSP_DASHBOARD,
		"javax.portlet.name=" + ECRFUserPortletKeys.DASHBOARD,
		"javax.portlet.resource-bundle=content.Language",
		"javax.portlet.security-role-ref=power-user,user"
	},
	service = Portlet.class
)
public class DashboardPortlet extends MVCPortlet {

	@Override
	public void render(RenderRequest renderRequest, RenderResponse renderResponse)
			throws IOException, PortletException {
		ThemeDisplay themeDisplay = (ThemeDisplay)renderRequest.getAttribute(WebKeys.THEME_DISPLAY);
		long groupId = themeDisplay.getScopeGroupId();
		
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy/M/d");
		
		JSONObject object = JSONFactoryUtil.createJSONObject();
		JSONArray dataArr = JSONFactoryUtil.createJSONArray();
		
		// get all crf by group id
		ArrayList<CRF> allCRFList = new ArrayList<>();
		allCRFList.addAll(_crfLocelService.getCRFByGroupId(groupId));
		
		for(int crfIndex=0; crfIndex<allCRFList.size(); crfIndex++) {
			// get linkCRF List by crf id
			CRF crf = allCRFList.get(crfIndex);
			ArrayList<LinkCRF> crfLinkList = new ArrayList<>();
			crfLinkList.addAll(_linkCRFlocalService.getLinkCRFByG_C(groupId, crf.getCrfId()));
						
			JSONObject crfObj = JSONFactoryUtil.createJSONObject();
			JSONObject dataObj = JSONFactoryUtil.createJSONObject();
			
			JSONArray yearArr = JSONFactoryUtil.createJSONArray();
			JSONArray monthArr = JSONFactoryUtil.createJSONArray();
			
			HashMap<String, Integer> yearMap = new HashMap<>();
			HashMap<String, Integer> monthMap = new HashMap<>();
			
			// get answer data from link
			// get visit date from answer data
			// crf - subjectId - visitdate
			for(int linkIndex=0; linkIndex<crfLinkList.size(); linkIndex++) {
				LinkCRF link = crfLinkList.get(linkIndex);
				String answerFormStr = _dataTypeLocalService.getStructuredData(link.getStructuredDataId());
				
				//_log.info(answerFormStr);
				
				JSONObject answerObj = null;
				
				try {
					answerObj = JSONFactoryUtil.createJSONObject(answerFormStr);
				} catch (Exception e) {
					e.printStackTrace();
				}
				
				Date visitDate = null;
				if(Validator.isNotNull(answerObj) && answerObj.has("visit_date")){
					visitDate = new Date(Long.valueOf(answerObj.getString("visit_date")));
					//_log.info(sdf.format(visitDate));
					
					Calendar cal = Calendar.getInstance();
					cal.setTime(visitDate);
					
					int year = cal.get(Calendar.YEAR);
					int month = cal.get(Calendar.MONTH)+1;
					
					String yearMonth = year + "-" + month;
					
					yearMap.merge(String.valueOf(year), 1, Integer::sum);
					monthMap.merge(String.valueOf(yearMonth), 1, Integer::sum);
				}
			}
			
			yearArr = convertMapToJsonArray(yearMap);
			monthArr = convertMapToJsonArray(monthMap);
			
			yearArr = sortJSONArray(yearArr, "x");
			monthArr = sortJSONArray(monthArr, "x");
			
			//_log.info(yearArr.toString());
			//_log.info(monthArr.toString());
				
			dataObj.put("yearData", yearArr);
			dataObj.put("monthData", monthArr);
			crfObj.put("id", crf.getCrfId());
			crfObj.put("data", dataObj);
			dataArr.put(crfObj);
		}
		
		object.put("chart-data", dataArr);
		
		// json format
		// {chart-data : [ {crfid:{}}, {crfid:{}}, ... ]}
		// crfid : { annual : [], monthly : [] }
		// { annual : [ {year : freq}, ...] }
		// { monthly : [ {year-month : freq}, ... ]
		
		renderRequest.setAttribute("chartDataObj", object);
		
		super.render(renderRequest, renderResponse);
	}
	
	private JSONArray sortJSONArray(JSONArray array, String key) {
		JSONArray sortedArray = JSONFactoryUtil.createJSONArray();
		
		List<JSONObject> jsonValues = new ArrayList<JSONObject>();
		for(int i=0; i<array.length(); i++) {
			jsonValues.add(array.getJSONObject(i));
		}
		
		Collections.sort(jsonValues, new Comparator<JSONObject>() {
			@Override
			public int compare(JSONObject o1, JSONObject o2) {
				String valA = o1.getString(key);
				String valB = o2.getString(key);
				
				return valA.compareTo(valB);
			}
		});
		
		for(int i=0; i<array.length(); i++) {
			sortedArray.put(jsonValues.get(i));
		}
		
		return sortedArray;
	}
	
	private JSONArray convertMapToJsonArray(HashMap<String, Integer> map) {
		JSONArray array = JSONFactoryUtil.createJSONArray();
		
		List<String> keySet = new ArrayList<>(map.keySet());

        // value 값으로 오름차순 정렬
        keySet.sort((o1, o2) -> map.get(o1).compareTo(map.get(o2)));
		
		for(String key : keySet) {
			Integer value = map.get(key);
			//_log.info("key/value:/ " + key+"/"+value);
			
			JSONObject obj = JSONFactoryUtil.createJSONObject();
			
			obj.put("x", key);
			obj.put("y", value);
			array.put(obj);
		}
		
		return array;
	}
	
	private Log _log = LogFactoryUtil.getLog(DashboardPortlet.class);
	
	@Reference
	private CRFLocalService _crfLocelService;
	
	@Reference
	private LinkCRFLocalService _linkCRFlocalService;
	
	@Reference
	private CRFSubjectLocalService _crfSubjectLocalService;
	
	@Reference
	private SubjectLocalService _subjectLocalService;
	
	@Reference
	private DataTypeLocalService _dataTypeLocalService;
	
	@Reference
	private StructuredDataLocalService _sdLocalService;
}
