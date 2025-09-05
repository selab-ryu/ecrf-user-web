package ecrf.user.teeth.portlet;

import com.liferay.portal.kernel.dao.orm.QueryUtil;
import com.liferay.portal.kernel.json.JSONFactoryUtil;
import com.liferay.portal.kernel.json.JSONObject;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCPortlet;

import java.util.List;

import javax.portlet.Portlet;
import javax.portlet.PortletException;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;

import org.osgi.service.component.annotations.Component;

import ecrf.user.teeth.constants.ECRFTeethPortletKeys;
import teeth.model.TreatmentHistory;
import teeth.service.TreatmentHistoryLocalServiceUtil;

/**
 * @author dev-ryu
 */
@Component(
	immediate = true,
	property = {
		"com.liferay.portlet.display-category=category.ecrf-user",
		"com.liferay.portlet.header-portlet-css=/css/main.css",
		"com.liferay.portlet.instanceable=false",
		"javax.portlet.display-name=Teeth Module",
		"javax.portlet.init-param.template-path=/",
		"javax.portlet.init-param.view-template=/teeth/view/teeth-view.jsp",
		"javax.portlet.name=" + ECRFTeethPortletKeys.ECRFTEETH,
		"javax.portlet.resource-bundle=content.Language",
		"javax.portlet.security-role-ref=power-user,user"
	},
	service = Portlet.class
)
public class ECRFTeethPortlet extends MVCPortlet {
	@Override
    public void render(RenderRequest renderRequest, RenderResponse renderResponse) throws PortletException {
		try 
		{
			//long patientID = ParamUtil.getLong(renderRequest, "patientID");
			long PatientID = 1001; //임시 PatientID
			boolean isPermanent = false;
			String JSONString = convertJSONString();
			_log.info(JSONString);
			
			// 영구치(11~18, 21~28, 31~38, 41~48)는 checkPermanent=true
			isPermanent = processTeethRange(renderRequest, PatientID, 11, 48, true, isPermanent);

			// 유치(51~55, 61~65, 71~75, 81~85)는 검사 없이 그냥 세팅
			isPermanent = processTeethRange(renderRequest, PatientID, 51, 85, false, isPermanent);
			
			renderRequest.setAttribute("patientID", PatientID);
			renderRequest.setAttribute("isPermanent", isPermanent);
			
			super.render(renderRequest, renderResponse);
		}
		catch(Exception e)
		{
			_log.info("Error During Render MainPage!");
			e.printStackTrace();
		}
	}
	
	public static String convertJSONString() {
		try
		{
			List<TreatmentHistory> list = TreatmentHistoryLocalServiceUtil.getTreatmentHistories(QueryUtil.ALL_POS, QueryUtil.ALL_POS);
			_log.info(list);
	        JSONObject root = JSONFactoryUtil.createJSONObject();
	        _log.info("-----root");
	        JSONObject grid = JSONFactoryUtil.createJSONObject();
	        _log.info("-----grid");
	        
	        for (TreatmentHistory th : list) {
	            JSONObject entry = JSONFactoryUtil.createJSONObject();

	            if(th.getState() != null) 
	            {
	            	entry.put("tt_state", th.getState());
	            } 
	            else 
	            {
	            	entry.put("tt_state", "");
	            }
	            if(th.getTreatment() != null)
	            {
	            	entry.put("tt_treatment", th.getTreatment());
	            }
	            else
	            {
	            	entry.put("tt_treatment", "");
	            }
	            entry.put("treatment_date", th.getTreatmentDate().getTime());
	            entry.put("tt_create_date", th.getCreateDate().getTime());
	            entry.put("teeth_number", th.getTeethNum());
	            entry.put("tt_modified_date", th.getModifiedDate().getTime());

	            // treatmentID를 문자열 키로 사용
	            grid.put(
	                String.valueOf(th.getTreatmentID()),
	                entry
	            );
	        }
	        _log.info("-----entry");
	        
	        root.put("tt_grid", grid);
	        
	        _log.info("------put");

	        // 4. 최종 JSON 문자열로 변환
	        String JSONString = root.toString();

	        return JSONString;
			
			
		}
		catch(Exception e)
		{
			e.printStackTrace();
			return null;
		}
	}
	
	private boolean processTeethRange(RenderRequest Request, long PatientID, long from, long to, boolean checkPermanent, boolean isPermanent)
	{
		for(long i = from; i <= to; i++)
		{
			List<TreatmentHistory> HT = TreatmentHistoryLocalServiceUtil.getPatientTreatmentListByTeethNum(PatientID, i);
			if (checkPermanent && !HT.isEmpty()) 
			{
				isPermanent = true;
			}
			Request.setAttribute("teeth" + i, HT);
	        //_log.info("teeth" + i + " : " + HT);
		}
		return isPermanent;
	}
	
	private static Log _log = LogFactoryUtil.getLog(ECRFTeethPortlet.class);
	
}