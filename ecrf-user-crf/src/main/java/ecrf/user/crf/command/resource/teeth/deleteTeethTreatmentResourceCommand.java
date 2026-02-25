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
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.Validator;
import com.liferay.portal.kernel.util.WebKeys;
import com.liferay.portal.kernel.workflow.WorkflowConstants;
import com.sx.icecap.model.DataType;
import com.sx.icecap.model.StructuredData;
import com.sx.icecap.service.DataTypeLocalService;

import java.io.PrintWriter;
import java.util.List;

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
import teeth.service.TreatmentHistoryLocalService;

@Component(
	    property = {
	        "javax.portlet.name=" + ECRFUserPortletKeys.CRF,
	        "mvc.command.name="+ ECRFUserMVCCommand.RESOURCE_DELETE_TREATMENT
	    },
	    service = MVCResourceCommand.class
	)
public class deleteTeethTreatmentResourceCommand extends BaseMVCResourceCommand{

	@Override
	protected void doServeResource(ResourceRequest resourceRequest, ResourceResponse resourceResponse) throws Exception {
		long treatmentId = ParamUtil.getLong(resourceRequest, "treatmentId", 0);
		TreatmentHistory treatment = null;
		
		if(treatmentId > 0) {
			treatment = _treatmentHistoryLocalService.getTreatmentHistory(treatmentId);
		}

		resourceResponse.setContentType("application/json");
		PrintWriter writer = resourceResponse.getWriter();
		JSONObject rpObj = JSONFactoryUtil.createJSONObject();

		ThemeDisplay themeDisplay = (ThemeDisplay)resourceRequest.getAttribute(WebKeys.THEME_DISPLAY);
		long groupId = themeDisplay.getScopeGroupId();
		User user = themeDisplay.getUser();
		ServiceContext serviceContext = ServiceContextFactory.getInstance(TreatmentAudit.class.getName(), resourceRequest);

		long crfId = 0;
		long subjectId = 0;
		long linkId = 0;

		if(Validator.isNotNull(treatment)) {
			subjectId = treatment.getPatientID();
			crfId = treatment.getCrfId();
			linkId = treatment.getLinkId();
		}

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

		// crf check
		if(crfId > 0) {
			crf = _crfLocalService.getCRF(crfId);

			// link check
            if(linkId > 0) {
            	link = _linkCRFLocalService.getLinkCRF(linkId);
            } else {
            	_log.error("link id is 0");
            	rpObj.put("status", "error");
            	rpObj.put("msg", "link id is zero");
            	writer.write(rpObj.toJSONString());
        	    writer.flush();
            	return;
            }
            
            dataTypeId = crf.getDatatypeId();
            
			// datatype check
            if(dataTypeId > 0) {
                dataType = _dataTypeLocalService.getDataType(dataTypeId);        
            } else {
            	_log.error("datatype id is 0");
            	rpObj.put("status", "error");
            	rpObj.put("msg", "datatype id is zero");
            	writer.write(rpObj.toJSONString());
        	    writer.flush();
            	return;
            }
            
			// grid term check
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
            	rpObj.put("status", "error");
            	rpObj.put("msg", "datatype is null");
            	writer.write(rpObj.toJSONString());
        	    writer.flush();
            	return;
            }
        }

		// grid not exist error
		if(!isGridExist) {
        	rpObj.put("status", "error");
        	rpObj.put("msg", "grud is not exist");
        	writer.write(rpObj.toJSONString());
    	    writer.flush();
        	return;
        }

		// delete treatment
		if(treatmentId > 0) {
			treatment = _treatmentHistoryLocalService.deleteTreatmentHistory(treatmentId);
			TreatmentAudit audit = _treatmentAuditLocalService.AddAudit(
				crfId,
				linkId,
				subjectId,
				treatment.getTeethNum(), 
				user.getUserId(), 
				treatment.getTreatmentDate(),
				"Delete",
				treatment.getState() + " / " + treatment.getTreatment(),
				"-",
				serviceContext);
		} else {
			_log.error("treatment id is zero");
			rpObj.put("status", "error");
			rpObj.put("mag", "treatment id is zero");
			writer.write(rpObj.toJSONString());
			writer.flush();
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
        	rpObj.put("status", "error");
        	rpObj.put("msg", "link is null");
        	writer.write(rpObj.toJSONString());
    	    writer.flush();
        	return;
        }

		rpObj.put("status", "success");
	    writer.write(rpObj.toJSONString());
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

	private Log _log = LogFactoryUtil.getLog(deleteTeethTreatmentResourceCommand.class);
}
