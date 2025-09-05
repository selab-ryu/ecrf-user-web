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
import com.liferay.portal.kernel.util.Validator;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
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
	        "mvc.command.name="+ teethTreatmentMVCCommand.ADD_TREATMENT
	    },
	    service = MVCResourceCommand.class
	)
public class addTeethTreatmentResourceCommand extends BaseMVCResourceCommand {

	@Override
	protected void doServeResource(ResourceRequest resourceRequest, ResourceResponse resourceResponse)
	        throws Exception {

		String jsonStr = new BufferedReader(new InputStreamReader(resourceRequest.getPortletInputStream()))
			        .lines().collect(Collectors.joining());
	
	    JSONObject jsonObject = JSONFactoryUtil.createJSONObject(jsonStr);
	    JSONArray treatmentsArray = jsonObject.getJSONArray("treatments");

	    for (int i = 0; i < treatmentsArray.length(); i++) {
	        JSONObject treatment = treatmentsArray.getJSONObject(i);

	        String EditUserId = treatment.getString("EditUserId");
	        String treatmentDate = treatment.getString("treatmentDate");
	        String mainCategory = treatment.getString("mainCategory");
	        String selectedTreatment = treatment.getString("selectedTreatment");
	        String selectedTeeth1 = treatment.getString("selectedTeeth");
	        String State = treatment.getString("selectedState");
	        ServiceContext serviceContext = ServiceContextFactory.getInstance(TreatmentAudit.class.getName(), resourceRequest);

	        _log.info("JSON Treatment Processing: " + treatment.toString());

	        // TODO: process logic (eg: DB save)
	        
	        // state data check
	        if (Validator.isNull(State) || State.equals("undefined")) {
                State = null;   
            }
	        
            String selectedTeeth = java.net.URLDecoder.decode(selectedTeeth1, "UTF-8");
            selectedTeeth = selectedTeeth.replaceAll("[^0-9,]", ""); // only num and comma
            
            // string to date
            Date treatmentDateParsed = null;
            try {
                treatmentDateParsed = new SimpleDateFormat("yyyy-MM-dd").parse(treatmentDate);
            } catch (Exception e) {
                //out.print("date parsing error : " + e.getMessage());
                return;
            }
            
            String[] teethNumbers = selectedTeeth.split(",");
            
            for (String teethNumber : teethNumbers) {
                // Treatment ID for each teeth
                String Treatment = selectedTreatment;
                Date EditedDate = new Date(); 
                long patientId = 1001; // temp id
                long TN = Long.parseLong(teethNumber);
                
                long UserId = Long.parseLong(EditUserId);
                
                // save data
                TreatmentHistory TH = TreatmentHistoryLocalServiceUtil.AddHistory(patientId, TN, treatmentDateParsed, Treatment, State, EditedDate, UserId, serviceContext);
                TreatmentAudit audit = TreatmentAuditLocalServiceUtil.AddAudit(TN, UserId, treatmentDateParsed, "Add", "-" , Treatment, serviceContext);

                if(TH == null)
                {
                    // when failed
                }
                else
                {
                    // when success
                    //out.print(" data saved : " + teethNumber + "\n");
                }
            }
	    }

	    resourceResponse.setContentType("application/json");
	    PrintWriter writer = resourceResponse.getWriter();
	    writer.write("{\"status\":\"success\"}");
	    writer.flush();
	}
	
	private Log _log = LogFactoryUtil.getLog(addTeethTreatmentResourceCommand.class);
}
