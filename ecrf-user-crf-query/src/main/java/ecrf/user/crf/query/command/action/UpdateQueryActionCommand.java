package ecrf.user.crf.query.command.action;

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
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.WebKeys;
import com.liferay.portal.kernel.workflow.WorkflowConstants;
import com.sx.icecap.model.DataType;
import com.sx.icecap.model.StructuredData;
import com.sx.icecap.service.DataTypeLocalService;

import java.util.List;

import javax.portlet.ActionRequest;
import javax.portlet.ActionResponse;
import javax.portlet.PortletRequest;
import javax.portlet.PortletURL;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.constants.ECRFUserWebKeys;
import ecrf.user.constants.attribute.ECRFUserCRFDataAttributes;
import ecrf.user.model.CRFAutoquery;
import ecrf.user.model.CRFHistory;
import ecrf.user.model.Subject;
import ecrf.user.service.CRFAutoqueryLocalService;
import ecrf.user.service.CRFHistoryLocalService;
import ecrf.user.service.SubjectLocalService;

@Component
(
	property = {
		"javax.portlet.name=" + ECRFUserPortletKeys.CRF_QUERY,
		"mvc.command.name=" + ECRFUserMVCCommand.ACTION_COMFIRM_CRF_QUERY
	},
	service = MVCActionCommand.class
)
public class UpdateQueryActionCommand extends BaseMVCActionCommand{
	@Override
	protected void doProcessAction(ActionRequest actionRequest, ActionResponse actionResponse) throws Exception {
		_log.info("Edit Query Action Start");
		ServiceContext queryServiceContext = ServiceContextFactory.getInstance(CRFAutoquery.class.getName(), actionRequest);
		ServiceContext dataTypeServiceContext = ServiceContextFactory.getInstance(DataType.class.getName(), actionRequest);
		ServiceContext historyServiceContext = ServiceContextFactory.getInstance(CRFHistory.class.getName(), actionRequest);

		ThemeDisplay themeDisplay = (ThemeDisplay)actionRequest.getAttribute(WebKeys.THEME_DISPLAY);

		long crfId = ParamUtil.getLong(actionRequest, ECRFUserCRFDataAttributes.CRF_ID);
		long sId = ParamUtil.getLong(actionRequest, "sId");
		long sdId = ParamUtil.getLong(actionRequest, "sdId");
		long queryId = ParamUtil.getLong(actionRequest, "queryId");
		String queryTermName = ParamUtil.getString(actionRequest, "queryTermName");
		String queryChangeValue = ParamUtil.getString(actionRequest, "queryChangeValue");
		String queryValue = ParamUtil.getString(actionRequest, "queryValue");
		int queryComfirm = ParamUtil.getInteger(actionRequest, "queryComfirm");
		String queryComment = ParamUtil.getString(actionRequest, "queryComment");
		_log.info("edit action : " + sId + " / " + sdId + " / " + queryId + " / " + queryComfirm + " / " + queryComment);
		
		StructuredData sd = _dataTypeLocalService.getStructuredData(sdId);
		String crfFormStr = _dataTypeLocalService.getDataTypeStructure(sd.getDataTypeId());
		JSONArray crfForm = JSONFactoryUtil.createJSONObject(crfFormStr).getJSONArray("terms");
		String answerFormStr = sd.getStructuredData();
		CRFAutoquery query = _queryLocalService.getCRFAutoquery(queryId);
		JSONObject answerForm = JSONFactoryUtil.createJSONObject(answerFormStr);
		for(int i = 0; i < crfForm.length(); i++) {
			if(crfForm.getJSONObject(i).getString("termType").equals("List")) {	
				JSONArray tempArr = JSONFactoryUtil.createJSONArray();
				tempArr.put(queryChangeValue);
				queryChangeValue = tempArr.toString();
			}
		}
		switch(queryComfirm) {
		case 0:
			_queryLocalService.comfirmAutoquery(queryId, queryComfirm, queryValue, queryChangeValue, queryComment, queryServiceContext);
		case 1:
			if(answerForm.has(query.getQueryTermName())) {
				answerForm.put(query.getQueryTermName(), queryChangeValue);
				_dataTypeLocalService.updateStructuredData(sdId, 0, sd.getDataTypeId(), answerForm.toString(), WorkflowConstants.STATUS_APPROVED, dataTypeServiceContext);
				Subject subject = _subjectLocalService.getSubject(sId);
				List<CRFHistory> prevHistoryList = _historyLocalService.getCRFHistoryBySubjectId(sId);
				CRFHistory prevHistory = prevHistoryList.get(prevHistoryList.size() - 1);
				for(int i =  prevHistoryList.size() - 1; i > -1; i--) {
					prevHistory = prevHistoryList.get(i);
					if(prevHistory.getStructuredDataId() == sdId) break;
				}
				_historyLocalService.addCRFHistory(subject.getName(), sId, subject.getSerialId(), sdId, sd.getDataTypeId(), prevHistory.getCurrentJSON(), answerForm.toString(), 0, "1.0.0", historyServiceContext);
			}
			_queryLocalService.comfirmAutoquery(queryId, queryComfirm, queryValue, queryChangeValue, queryComment, queryServiceContext);
			break;
		case 2:
			if(answerForm.has(query.getQueryTermName())) {
				answerForm.put(query.getQueryTermName(), queryChangeValue);
				_dataTypeLocalService.updateStructuredData(sdId, 0, sd.getDataTypeId(), answerForm.toString(), WorkflowConstants.STATUS_APPROVED, dataTypeServiceContext);
				Subject subject = _subjectLocalService.getSubject(sId);
				List<CRFHistory> prevHistoryList = _historyLocalService.getCRFHistoryBySubjectId(sId);
				CRFHistory prevHistory = prevHistoryList.get(prevHistoryList.size() - 1);
				for(int i =  prevHistoryList.size() - 1; i > -1; i--) {
					prevHistory = prevHistoryList.get(i);
					if(prevHistory.getStructuredDataId() == sdId) break;
				}
				_historyLocalService.addCRFHistory(subject.getName(), sId, subject.getSerialId(), sdId, sd.getDataTypeId(), prevHistory.getCurrentJSON(), answerForm.toString(), 0, "1.0.0", historyServiceContext);
			}
			_queryLocalService.comfirmAutoquery(queryId, queryComfirm, queryValue, queryChangeValue, queryComment, queryServiceContext);
			break;
		default:
			_queryLocalService.comfirmAutoquery(queryId, queryComfirm, queryValue, queryChangeValue, queryComment, queryServiceContext);
		}
		
		String renderCommand = ECRFUserMVCCommand.RENDER_LIST_CRF_QUERY;
		PortletURL renderURL = PortletURLFactoryUtil.create(
				actionRequest, 
				themeDisplay.getPortletDisplay().getId(), 
				themeDisplay.getPlid(), 
				PortletRequest.RENDER_PHASE);
		renderURL.setParameter(ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME, renderCommand);
		renderURL.setParameter(ECRFUserCRFDataAttributes.CRF_ID, String.valueOf(crfId));
		actionResponse.sendRedirect(renderURL.toString());
	}
	
	private Log _log = LogFactoryUtil.getLog(UpdateQueryActionCommand.class);
	
	@Reference
	private SubjectLocalService _subjectLocalService;
	
	@Reference
	private CRFHistoryLocalService _historyLocalService;
	
	@Reference
	private DataTypeLocalService _dataTypeLocalService;
	
	@Reference
	private CRFAutoqueryLocalService _queryLocalService;
}