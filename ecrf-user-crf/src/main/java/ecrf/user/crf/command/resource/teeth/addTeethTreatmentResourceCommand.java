package ecrf.user.crf.command.resource.teeth;

import com.liferay.portal.kernel.json.JSONArray;
import com.liferay.portal.kernel.json.JSONFactoryUtil;
import com.liferay.portal.kernel.json.JSONObject;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.model.User;
import com.liferay.portal.kernel.portlet.bridges.mvc.BaseMVCResourceCommand;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCResourceCommand;
import com.liferay.portal.kernel.service.ServiceContext;
import com.liferay.portal.kernel.service.ServiceContextFactory;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.util.Validator;
import com.liferay.portal.kernel.util.WebKeys;
import com.liferay.portal.kernel.workflow.WorkflowConstants;
import com.sx.icecap.model.DataType;
import com.sx.icecap.model.StructuredData;
import com.sx.icecap.service.DataTypeLocalService;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;

import javax.portlet.ResourceRequest;
import javax.portlet.ResourceResponse;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.crf.util.data.TeethUtil;
import ecrf.user.model.CRF;
import ecrf.user.model.CRFHistory;
import ecrf.user.model.LinkCRF;
import ecrf.user.model.Subject;
import ecrf.user.service.CRFHistoryLocalService;
import ecrf.user.service.CRFLocalService;
import ecrf.user.service.LinkCRFLocalService;
import ecrf.user.service.SubjectLocalService;
import teeth.model.TreatmentAudit;
import teeth.model.TreatmentHistory;
import teeth.service.TreatmentAuditLocalService;
import teeth.service.TreatmentAuditLocalServiceUtil;
import teeth.service.TreatmentHistoryLocalService;
import teeth.service.TreatmentHistoryLocalServiceUtil;


@Component(
	    property = {
	        "javax.portlet.name=" + ECRFUserPortletKeys.CRF,
	        "mvc.command.name="+ ECRFUserMVCCommand.RESOURCE_ADD_TREATMENT
	    },
	    service = MVCResourceCommand.class
	)
public class addTeethTreatmentResourceCommand extends BaseMVCResourceCommand {

	@Override
	protected void doServeResource(ResourceRequest resourceRequest, ResourceResponse resourceResponse)
	        throws Exception {
		ThemeDisplay themeDisplay = (ThemeDisplay)resourceRequest.getAttribute(WebKeys.THEME_DISPLAY);
		long groupId = themeDisplay.getScopeGroupId();
        User user = themeDisplay.getUser();
        
        resourceResponse.setContentType("application/json");
        PrintWriter writer = resourceResponse.getWriter();
        
        JSONObject responseJson = JSONFactoryUtil.createJSONObject();
        
        String jsonStr = new BufferedReader(new InputStreamReader(resourceRequest.getPortletInputStream()))
			        .lines().collect(Collectors.joining());

        _log.info("params : " + jsonStr);

	    JSONObject jsonObject = JSONFactoryUtil.createJSONObject(jsonStr);
	    JSONArray treatmentsArray = jsonObject.getJSONArray("treatments");

        long crfId = Long.parseLong(jsonObject.getString("crfId"));
        long subjectId = Long.parseLong(jsonObject.getString("subjectId"));
        long linkId = Long.parseLong(jsonObject.getString("linkId"));

        // grid term check
        // grid term name : teethTreatmentGrid
        boolean isGridExist = false;
        String gridName = "teethTreatmentGrid";
        CRF crf = null;
        LinkCRF link = null;
        
        long dataTypeId = 0;
        DataType dataType = null;
        
        Subject subject = null;
        if(subjectId > 0) {
        	subject = _subjectLocalService.getSubject(subjectId);
        }
        
        if(crfId > 0) {
            crf = _crfLocalService.getCRF(crfId);
            if(linkId > 0) {
            	link = _linkCRFLocalService.getLinkCRF(linkId);
            } else {
            	_log.error("link id is 0");
            	responseJson.put("status", "error");
            	responseJson.put("msg", "link id is zero");
            	writer.write(responseJson.toJSONString());
        	    writer.flush();
            	return;
            }
            
            dataTypeId = crf.getDatatypeId();
            
            if(dataTypeId > 0) {
                dataType = _dataTypeLocalService.getDataType(dataTypeId);        
            } else {
            	_log.error("datatype id is 0");
            	responseJson.put("status", "error");
            	responseJson.put("msg", "datatype id is zero");
            	writer.write(responseJson.toJSONString());
        	    writer.flush();
            	return;
            }
            
            if(Validator.isNotNull(dataType)) {
            	String formStr = _dataTypeLocalService.getDataTypeStructure(dataTypeId);
            	//_log.info(formStr);
            	JSONObject formObj = JSONFactoryUtil.createJSONObject(formStr);
            	JSONArray termArr = formObj.getJSONArray("terms");
            	
            	for(int i=0; i<termArr.length(); i++) {
            		JSONObject termObj = termArr.getJSONObject(i);
            		if(termObj.getString("termName").equals(gridName)){
            			isGridExist = true;
            		}
            	}
            } else {
            	_log.error("datatype is null");
            	responseJson.put("status", "error");
            	responseJson.put("msg", "datatype is null");
            	writer.write(responseJson.toJSONString());
        	    writer.flush();
            	return;
            }
        }
                
        if(!isGridExist) {
        	responseJson.put("status", "error");
        	responseJson.put("msg", "grud is not exist");
        	writer.write(responseJson.toJSONString());
    	    writer.flush();
        	return;
        }

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
                TreatmentHistory TH = _treatmentHistoryLocalService.AddHistory(crfId, linkId, subjectId, TN, treatmentDateParsed, Treatment, State, EditedDate, UserId, serviceContext);
                
                TreatmentAudit audit = _treatmentAuditLocalService.AddAudit(
                		crfId,
                		linkId,
                		subjectId,
                		TH.getTeethNum(), 
        				user.getUserId(), 
        				TH.getTreatmentDate(),
        				"Add",
        				"-",
        				TH.getState() + " / " + TH.getTreatment(),
        				serviceContext);

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

        // make grid term data
        // update grid term data
	    if(Validator.isNotNull(link)) {
        	// whole data
	    	String dataStr = _dataTypeLocalService.getStructuredData(link.getStructuredDataId());
        	JSONObject dataObj = JSONFactoryUtil.createJSONObject(dataStr);
        	_log.info(dataStr);
        	
        	// grid data
        	List<TreatmentHistory> list = _treatmentHistoryLocalService.getTreatmentsByG_C_P_L(groupId, crfId, subjectId, linkId);
        	String gridDataStr = TeethUtil.convertJSONString(list);
        	JSONObject gridObj = JSONFactoryUtil.createJSONObject(gridDataStr);
        	_log.info(gridDataStr);
        	
        	// update grid data
        	dataObj.put(gridName, gridObj);
        	
        	ServiceContext sdServiceContext = ServiceContextFactory.getInstance(StructuredData.class.getName(), resourceRequest);
        	ServiceContext historyServiceContext = ServiceContextFactory.getInstance(CRFHistory.class.getName(), resourceRequest);
        	
        	String dataContent = dataObj.toJSONString();
        	
        	StructuredData  storedData = _dataTypeLocalService.updateStructuredData(
        			link.getStructuredDataId(),
					dataTypeId, 
					dataTypeId, 
					dataContent, 
					WorkflowConstants.STATUS_APPROVED, sdServiceContext);
        	
        	List<CRFHistory> prevHistoryList = _historyLocalService.getCRFHistoryByG_C_S_SD(groupId, crfId, subjectId, link.getStructuredDataId());
			CRFHistory prevHistory = prevHistoryList.get(0);
			
			_historyLocalService.addCRFHistory(subject.getName(), subjectId, subject.getSerialId(), storedData.getPrimaryKey(), crfId, prevHistory.getCurrentJSON(), dataContent, 0, "1.0.0", historyServiceContext);        	
        } else {
        	_log.error("link is null");
        	responseJson.put("status", "error");
        	responseJson.put("msg", "link is null");
        	writer.write(responseJson.toJSONString());
    	    writer.flush();
        	return;
        }
	    
	    responseJson.put("status", "success");
	    writer.write(responseJson.toJSONString());
	    writer.flush();
	}
	
	@Reference
	private SubjectLocalService _subjectLocalService;
	
    @Reference
    private CRFLocalService _crfLocalService;

    @Reference
    private DataTypeLocalService _dataTypeLocalService;
    
    @Reference
    private LinkCRFLocalService _linkCRFLocalService;
    
    @Reference
	private CRFHistoryLocalService _historyLocalService;

    @Reference
    private TreatmentHistoryLocalService _treatmentHistoryLocalService;
    
    @Reference
    private TreatmentAuditLocalService _treatmentAuditLocalService;
    
	private Log _log = LogFactoryUtil.getLog(addTeethTreatmentResourceCommand.class);
}
