package ecrf.user.teeth.command.resource;

import com.liferay.portal.kernel.json.JSONArray;
import com.liferay.portal.kernel.json.JSONFactoryUtil;
import com.liferay.portal.kernel.json.JSONObject;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.BaseMVCResourceCommand;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCResourceCommand;
import com.liferay.portal.kernel.service.ServiceContext;
import com.liferay.portal.kernel.service.ServiceContextFactory;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.stream.Collectors;

import javax.portlet.ResourceRequest;
import javax.portlet.ResourceResponse;

import org.osgi.service.component.annotations.Component;

import ecrf.user.teeth.constants.ECRFTeethPortletKeys;
import ecrf.user.teeth.constants.teethTreatmentMVCCommand;
import teeth.model.TreatmentAudit;
import teeth.model.TreatmentHistory;
import teeth.service.TreatmentAuditLocalServiceUtil;
import teeth.service.TreatmentHistoryLocalServiceUtil;

@Component(
	    property = {
	        "javax.portlet.name=" + ECRFTeethPortletKeys.ECRFTEETH,
	        "mvc.command.name="+ teethTreatmentMVCCommand.DELETE_TREATMENT
	    },
	    service = MVCResourceCommand.class
	)
public class deleteTeethTreatmentResourceCommand extends BaseMVCResourceCommand{

	@Override
	protected void doServeResource(ResourceRequest resourceRequest, ResourceResponse resourceResponse)
			throws Exception {
		// TODO Auto-generated method stub
		 String jsonStr = new BufferedReader(new InputStreamReader(resourceRequest.getPortletInputStream()))
			        .lines().collect(Collectors.joining());

	    JSONObject jsonObject = JSONFactoryUtil.createJSONObject(jsonStr);
	    JSONArray treatmentsArray = jsonObject.getJSONArray("deleteData");
	    
	    for (int i = 0; i < treatmentsArray.length(); i++) {
	        JSONObject treatment = treatmentsArray.getJSONObject(i);

	        _log.info("JSON Treatment ó�� ��: " + treatment.toString());
	        String EditUserId = treatment.getString("userId");
	        String treatmentDateStr = treatment.getString("treatmentDate"); 
	        String mainCategory = treatment.getString("mainCategory");
	        String selectedTreatment = treatment.getString("selectedTreatment");
	        String selectedTeeth1 = treatment.getString("selectedTeeth");
	        String Status = treatment.getString("selectedStatus");
	        long selectedTreatmentID = treatment.getLong("selectedTreatmentID");
	        ServiceContext serviceContext = ServiceContextFactory.getInstance(
	        	    TreatmentAudit.class.getName(), resourceRequest);
	        
	        //SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");  // ��¥ ������ "2025-04-10" ������ ���
	        //Date treatmentDate = sdf.parse(treatmentDateStr);
	        
	        
	        long userId = Long.parseLong(EditUserId);
	        long patientId = 1001; //ParamUtil.getLong(request, "patientId");
	        long teethNum = Long.parseLong(selectedTeeth1);
	        TreatmentHistory treatments = TreatmentHistoryLocalServiceUtil. getPatientTreatmentByTreatmentID(selectedTreatmentID);
	        
	        treatments = TreatmentHistoryLocalServiceUtil.deleteTreatmentHistory(selectedTreatmentID);
	        TreatmentAudit audit = TreatmentAuditLocalServiceUtil.AddAudit(teethNum, userId, treatments.getTreatmentDate(), "delete",  Status, "-", serviceContext);
	        
	      
	    }
	}
	private Log _log = LogFactoryUtil.getLog(deleteTeethTreatmentResourceCommand.class);
}
