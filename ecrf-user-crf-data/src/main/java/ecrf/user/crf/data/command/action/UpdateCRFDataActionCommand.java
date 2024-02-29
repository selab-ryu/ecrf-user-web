package ecrf.user.crf.data.command.action;

import com.liferay.portal.kernel.json.JSONArray;
import com.liferay.portal.kernel.json.JSONFactoryUtil;
import com.liferay.portal.kernel.json.JSONObject;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.PortletURLFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.BaseMVCActionCommand;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCActionCommand;
import com.liferay.portal.kernel.service.ServiceContext;
import com.liferay.portal.kernel.service.ServiceContextFactory;
import com.liferay.portal.kernel.service.persistence.UserUtil;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.util.Constants;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.Validator;
import com.liferay.portal.kernel.util.WebKeys;
import com.liferay.portal.kernel.workflow.WorkflowConstants;
import com.sx.icecap.model.DataType;
import com.sx.icecap.model.StructuredData;
import com.sx.icecap.service.DataTypeLocalService;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

import javax.portlet.ActionRequest;
import javax.portlet.ActionResponse;
import javax.portlet.PortletException;
import javax.portlet.PortletRequest;
import javax.portlet.PortletURL;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserJspPaths;
import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.constants.ECRFUserUtil;
import ecrf.user.constants.ECRFUserWebKeys;
import ecrf.user.constants.attribute.ECRFUserCRFDataAttributes;
import ecrf.user.crf.data.util.RuleBaseAutoCalculation;
import ecrf.user.model.CRF;
import ecrf.user.model.CRFAutoquery;
import ecrf.user.model.CRFHistory;
import ecrf.user.model.LinkCRF;
import ecrf.user.model.Subject;
import ecrf.user.service.CRFAutoqueryLocalService;
import ecrf.user.service.CRFHistoryLocalService;
import ecrf.user.service.CRFLocalService;
import ecrf.user.service.LinkCRFLocalService;
import ecrf.user.service.SubjectLocalService;

@Component
(
	property = {
		"javax.portlet.name=" + ECRFUserPortletKeys.CRF_DATA,
		"mvc.command.name=" + ECRFUserMVCCommand.ACTION_ADD_CRF_DATA,
		"mvc.command.name=" + ECRFUserMVCCommand.ACTION_UPDATE_CRF_DATA,
	},
	service = MVCActionCommand.class
)

public class UpdateCRFDataActionCommand extends BaseMVCActionCommand{
	@Override
	protected void doProcessAction(ActionRequest actionRequest, ActionResponse actionResponse) throws Exception {
        SimpleDateFormat dateWithTimeFormat = new SimpleDateFormat("yyyy/MM/dd HH:mm");
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy/MM/dd");

        ThemeDisplay themeDisplay = (ThemeDisplay)actionRequest.getAttribute(WebKeys.THEME_DISPLAY);
        
        String cmd = ParamUtil.getString(actionRequest, Constants.CMD, Constants.ADD);
        
        long subjectId = ParamUtil.getLong(actionRequest, ECRFUserCRFDataAttributes.SUBJECT_ID, 0);
        long crfId = ParamUtil.getLong(actionRequest, ECRFUserCRFDataAttributes.CRF_ID, 0);
        long sdId = ParamUtil.getLong(actionRequest, ECRFUserCRFDataAttributes.STRUCTURED_DATA_ID, 0);
        
        _log.info("crf id : " + crfId);
        
        long dataTypeId = 0;
        
        Subject subject = null;
        CRF crf = null;
        
        try {        
        	if(subjectId > 0) {
    			subject = _subjectLocalService.getSubject(subjectId);
    		}
        	
        	if(crfId > 0) {
        		crf = _crfLocalService.getCRF(crfId);
        		dataTypeId = crf.getDatatypeId();
        		_log.info("datatype id : " + dataTypeId);
        	}
        } catch (Exception e) {
    		_log.error(e.getMessage());
    	}
        
		JSONObject jsonObject = _dataTypeLocalService.getDataTypeStructureJSONObject(dataTypeId);
		JSONArray crfForm = jsonObject.getJSONArray("terms");
		
		String visitDate = ParamUtil.getString(actionRequest, "visitDate");
		
		String[][] termDatas = new String[crfForm.length()][2];
		JSONObject answers = JSONFactoryUtil.createJSONObject();
		for(int i = 0; i < crfForm.length(); i++) {
			termDatas[i][0] = crfForm.getJSONObject(i).getString("termName");
			if(crfForm.getJSONObject(i).getString("termType").equals("List")) {	
				String jsonValue = ParamUtil.getString(actionRequest, crfForm.getJSONObject(i).getString("termName")).trim();
				if(!jsonValue.equals("-1")) {
					System.out.println("list jsonvalue : " + jsonValue);
					JSONArray tempArr = JSONFactoryUtil.createJSONArray();
					tempArr.put(jsonValue);
					answers.put(crfForm.getJSONObject(i).getString("termName"), tempArr);
					jsonValue = tempArr.toString().trim();
				}
			} else if(crfForm.getJSONObject(i).getString("termType").equals("Date")) {
				String jsonValue = ParamUtil.getString(actionRequest, crfForm.getJSONObject(i).getString("termName")).trim();
				if(!jsonValue.equals("")) {
					String[] splitDate = jsonValue.split("/");
					if(splitDate.length > 2) {
						Date convertDate = dateWithTimeFormat.parse(jsonValue);
						jsonValue = String.valueOf(convertDate.getTime());
						answers.put(crfForm.getJSONObject(i).getString("termName"), convertDate.getTime());
					}
					// add value as long
					answers.put(crfForm.getJSONObject(i).getString("termName"), ECRFUserUtil.isLong(jsonValue) ? Long.parseLong(jsonValue) : -1 );
				}
			} else if(crfForm.getJSONObject(i).getString("termType").equals("Numeric")) {
				int jsonValue = ParamUtil.getInteger(actionRequest, crfForm.getJSONObject(i).getString("termName"), 99999999);
				if(jsonValue < 99999999) {
					answers.put(crfForm.getJSONObject(i).getString("termName"), jsonValue);
				}
			} else if(crfForm.getJSONObject(i).getString("termType").equals("String")) {
				String jsonValue = ParamUtil.getString(actionRequest, crfForm.getJSONObject(i).getString("termName")).trim();
				if(!jsonValue.equals("")) {
					answers.put(crfForm.getJSONObject(i).getString("termName"), jsonValue);
				}
			} else if(crfForm.getJSONObject(i).getString("termType").equals("Boolean")) {
				int jsonValue = ParamUtil.getInteger(actionRequest, crfForm.getJSONObject(i).getString("termName"), 99999999);
				if(jsonValue < 99999999) {
					answers.put(crfForm.getJSONObject(i).getString("termName"), jsonValue);
				}
			}
		}
		
		String[] splitVisitDate = visitDate.split("/");
		if(splitVisitDate.length > 2) {
			Date convertVisitDate = dateFormat.parse(visitDate);
			visitDate = String.valueOf(convertVisitDate.getTime());
		}
		
		if(!visitDate.equals("")) {
			answers.put("visit_date", visitDate);
		}
		
		_log.info(answers.toJSONString());
		
		ServiceContext linkServiceContext = ServiceContextFactory.getInstance(LinkCRF.class.getName(), actionRequest);
		ServiceContext dataTypeServiceContext = ServiceContextFactory.getInstance(DataType.class.getName(), actionRequest);
		ServiceContext crfHistoryServiceContext = ServiceContextFactory.getInstance(CRFHistory.class.getName(), actionRequest);
		
		ServiceContext subjectServiceContext = ServiceContextFactory.getInstance(Subject.class.getName(), actionRequest);
		ServiceContext queryServiceContext = ServiceContextFactory.getInstance(CRFAutoquery.class.getName(), actionRequest);
		
		boolean hasMRIStudy = false;
		if(answers.has("mri_brain_bool") && answers.getInt("mri_brain_bool") == 1) {
			hasMRIStudy = true;
		}
		
		RuleBaseAutoCalculation autoApi = new RuleBaseAutoCalculation();
		
		answers = autoApi.ruleBaseAutoCalculate(answers, subject);
				
		if(cmd.equals(Constants.ADD) && Validator.isNotNull(subject)) {
			StructuredData sd = _dataTypeLocalService.addStructuredData(0, dataTypeId, answers.toJSONString(), WorkflowConstants.STATUS_APPROVED, dataTypeServiceContext);
			_linkCRFLocalService.addLinkCRF(subjectId, crfId, sd.getPrimaryKey(), linkServiceContext);
			_historyLocalService.addCRFHistory(subject.getName(), subjectId, subject.getSerialId(), sd.getPrimaryKey(), crfId, "", answers.toJSONString(), 0, "1.0.0", crfHistoryServiceContext);
			_queryLocalService.checkQuery(sd.getPrimaryKey(), crfForm, answers, subjectId, crfId, queryServiceContext);
		}
		else if(cmd.equals(Constants.UPDATE)) {
			// crf history by subject id & crf id
					
			StructuredData sd =	_dataTypeLocalService.updateStructuredData(sdId, 0, dataTypeId, answers.toJSONString(), WorkflowConstants.STATUS_APPROVED, dataTypeServiceContext);
			List<CRFHistory> prevHistoryList = _historyLocalService.getCRFHistoryByC_S(crfId, subjectId);
			
			CRFHistory prevHistory = prevHistoryList.get(prevHistoryList.size() - 1);
			for(int i =  prevHistoryList.size() - 1; i > -1; i--) {
				prevHistory = prevHistoryList.get(i);
				if(prevHistory.getStructuredDataId() == sdId) break;
			}
			
			_historyLocalService.addCRFHistory(subject.getName(), subjectId, subject.getSerialId(), sd.getPrimaryKey(), crfId, prevHistory.getCurrentJSON(), answers.toJSONString(), 0, "1.0.0", crfHistoryServiceContext);
			_queryLocalService.checkQuery(sd.getPrimaryKey(), crfForm, answers, subjectId, crfId, queryServiceContext);
		}
		
		String renderCommand = ECRFUserMVCCommand.RENDER_LIST_CRF_DATA;
		String listPath = ECRFUserJspPaths.JSP_LIST_CRF_DATA_UPDATE;
		PortletURL renderURL = PortletURLFactoryUtil.create(
				actionRequest, 
				themeDisplay.getPortletDisplay().getId(), 
				themeDisplay.getPlid(), 
				PortletRequest.RENDER_PHASE);
		renderURL.setParameter(ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME, renderCommand);
		renderURL.setParameter(ECRFUserWebKeys.LIST_PATH, listPath);
		renderURL.setParameter(ECRFUserCRFDataAttributes.CRF_ID, String.valueOf(crfId));
		actionResponse.sendRedirect(renderURL.toString());
	}
	
	private Log _log = LogFactoryUtil.getLog(UpdateCRFDataActionCommand.class);
	
	@Reference
	private SubjectLocalService _subjectLocalService;
	
	@Reference
	private CRFLocalService _crfLocalService;
	
	@Reference
	private LinkCRFLocalService _linkCRFLocalService;

	@Reference
	private DataTypeLocalService _dataTypeLocalService;
	
	@Reference
	private CRFHistoryLocalService _historyLocalService;
	
	@Reference
	private CRFAutoqueryLocalService _queryLocalService;
}
