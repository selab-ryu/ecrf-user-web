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
import java.util.Date;
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
	        "mvc.command.name="+ teethTreatmentMVCCommand.EDIT_TREATMENT
	        //"mvc.command.name=/teeth/addTreatment"
	    },
	    service = MVCResourceCommand.class
	)
public class editTeethTreatmentResourceCommand extends BaseMVCResourceCommand  {

	@Override
	protected void doServeResource(ResourceRequest resourceRequest, ResourceResponse resourceResponse)
			throws Exception {
		// TODO Auto-generated method stub
		 _log.info("JSON Treatment ó�� ��: ");
		 String jsonStr = new BufferedReader(new InputStreamReader(resourceRequest.getPortletInputStream()))
			        .lines().collect(Collectors.joining());

			    JSONObject jsonObject = JSONFactoryUtil.createJSONObject(jsonStr);
			    JSONArray treatmentsArray = jsonObject.getJSONArray("requests");
			    _log.info("jsonObject: " + jsonObject.toString());
			    _log.info("treatmentsArray: " + treatmentsArray.toString());
	
			    for (int i = 0; i < treatmentsArray.length(); i++) {
			        JSONObject treatment = treatmentsArray.getJSONObject(i);

			        String editUserIdStr = treatment.getString("EditUserId");
			        String treatmentIDStr = treatment.getString("treatmentID");
			        String selectedStatus = treatment.getString("selectedStatus");
			        String selectedTeethStr = treatment.getString("selectedTeeth");
			        String selectedPermanent = treatment.getString("selectedPermanent");
			        ServiceContext serviceContext = ServiceContextFactory.getInstance(
			        	    TreatmentAudit.class.getName(), resourceRequest);
			        
			        _log.info("ġ�� ����: " + treatment.toString());

			        try {
			            long editUserId = Long.parseLong(editUserIdStr);
			            long treatmentId = Long.parseLong(treatmentIDStr);
			            long selectedTeeth = Long.parseLong(selectedTeethStr);

			            Date editedDate = new Date();

			            // 1. ���� ġ�� ���� ��ȸ
			            TreatmentHistory past = TreatmentHistoryLocalServiceUtil.getPatientTreatmentByTreatmentID(treatmentId);
			            String pastTreatment = past.getTreatment();

			            // 2. ġ�� ��� ������Ʈ
			            TreatmentHistory updated = TreatmentHistoryLocalServiceUtil.UpdateHistory(
			                treatmentId,
			                selectedStatus,
			                selectedPermanent,
			                editedDate,
			                editUserId,
			                serviceContext
			            );

			            // 3. ���� �α� ����
			            TreatmentAudit audit = TreatmentAuditLocalServiceUtil.AddAudit(
			                selectedTeeth,
			                editUserId,
			                past.getTreatmentDate(),
			                "Edit",
			                pastTreatment,
			                selectedStatus,
			                serviceContext
			            );

			            if (updated != null && audit != null) {
			                _log.info("ġ�� ���� ���� �� ���� �α� �Ϸ� - TreatmentID: " + treatmentId);
			            } else {
			                _log.error("ġ�� ���� ���� ���� - TreatmentID: " + treatmentId);
			            }

			        } catch (Exception e) {
			            _log.error("���� �߻�: ", e);
			        }
			    }

			    // Ŭ���̾�Ʈ�� ���� ������
			    resourceResponse.setContentType("text/plain");
			    resourceResponse.getWriter().write("ġ�� ���� ���� �Ϸ�");
	}
	private Log _log = LogFactoryUtil.getLog(editTeethTreatmentResourceCommand.class);

}
