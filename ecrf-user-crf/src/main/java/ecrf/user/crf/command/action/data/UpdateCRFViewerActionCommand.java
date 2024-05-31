package ecrf.user.crf.command.action.data;

import com.liferay.portal.kernel.json.JSONFactoryUtil;
import com.liferay.portal.kernel.json.JSONObject;
import com.liferay.portal.kernel.portlet.PortletURLFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.BaseMVCActionCommand;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCActionCommand;
import com.liferay.portal.kernel.service.ServiceContext;
import com.liferay.portal.kernel.service.ServiceContextFactory;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.WebKeys;
import com.liferay.portal.kernel.workflow.WorkflowConstants;
import com.sx.icecap.constant.IcecapDataTypeAttributes;
import com.sx.icecap.constant.IcecapWebKeys;
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

import ecrf.user.constants.ECRFUserJspPaths;
import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.constants.ECRFUserWebKeys;
import ecrf.user.constants.attribute.ECRFUserCRFDataAttributes;
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
		"javax.portlet.name=" + ECRFUserPortletKeys.CRF,
		"mvc.command.name=" + ECRFUserMVCCommand.ACTION_ADD_CRF_VIEWER,
		"mvc.command.name=" + ECRFUserMVCCommand.ACTION_UPDATE_CRF_VIEWER,
	},
	service = MVCActionCommand.class
)
public class UpdateCRFViewerActionCommand extends BaseMVCActionCommand {
	@Override
	protected void doProcessAction(ActionRequest actionRequest, ActionResponse actionResponse) throws Exception {
		System.out.println("CRF Viewer update Action");
		
        ThemeDisplay themeDisplay = (ThemeDisplay)actionRequest.getAttribute(WebKeys.THEME_DISPLAY);
        
        boolean isUpdate = ParamUtil.getBoolean(actionRequest, "isUpdate");
		long subjectId =  ParamUtil.getLong(actionRequest, "subjectId", 0);
        long crfId = ParamUtil.getLong(actionRequest, ECRFUserCRFDataAttributes.CRF_ID, 0);
		long dataTypeId = ParamUtil.getLong(actionRequest, IcecapDataTypeAttributes.DATATYPE_ID, 0);
		long structuredDataId = ParamUtil.getLong(actionRequest, IcecapWebKeys.STRUCTURED_DATA_ID,  0);
		
		String dataContent = ParamUtil.getString(actionRequest, "dataContent", "");
		
		System.out.println("Save CRF Viewer : " + isUpdate + " , " + subjectId + " , " + crfId + " , " + dataTypeId + " , " + dataContent);
		
		ServiceContext linkServiceContext = ServiceContextFactory.getInstance(LinkCRF.class.getName(), actionRequest);
		ServiceContext dataTypeServiceContext = ServiceContextFactory.getInstance(DataType.class.getName(), actionRequest);
		ServiceContext crfHistoryServiceContext = ServiceContextFactory.getInstance(CRFHistory.class.getName(), actionRequest);
		
		ServiceContext subjectServiceContext = ServiceContextFactory.getInstance(Subject.class.getName(), actionRequest);
		ServiceContext queryServiceContext = ServiceContextFactory.getInstance(CRFAutoquery.class.getName(), actionRequest);

		JSONObject answer = JSONFactoryUtil.createJSONObject(dataContent);

		Subject subject = _subjectLocalService.getSubject(subjectId);
		CRF crf = _crfLocalService.getCRFByDataTypeId(dataTypeId);
//		dataContent = checkExcersizeJSON(answer, subject);
		
		if(!isUpdate) {
			StructuredData sd = _dataTypeLocalService.addStructuredData(0, dataTypeId, dataContent, WorkflowConstants.STATUS_APPROVED, dataTypeServiceContext);
			_linkCRFLocalService.addLinkCRF(subjectId, crfId, sd.getPrimaryKey(), linkServiceContext);
			//_historyLocalService.addCRFHistory(subject.getName(), subjectId, subject.getSerialId(), sd.getPrimaryKey(), crfId, "", dataContent, 0, "1.0.0", crfHistoryServiceContext);
			//_queryLocalService.checkQuery(sd.getPrimaryKey(), crfForm, JSONFactoryUtil.createJSONObject(dataContent), subjectId, crfId, queryServiceContext);
		}
		else {
			// crf history by subject id & crf id
					
			StructuredData sd =	_dataTypeLocalService.updateStructuredData(structuredDataId, 0, dataTypeId, dataContent, WorkflowConstants.STATUS_APPROVED, dataTypeServiceContext);
//			List<CRFHistory> prevHistoryList = _historyLocalService.getCRFHistoryByC_S(crfId, subjectId);
//			
//			CRFHistory prevHistory = prevHistoryList.get(prevHistoryList.size() - 1);
//			for(int i =  prevHistoryList.size() - 1; i > -1; i--) {
//				prevHistory = prevHistoryList.get(i);
//				if(prevHistory.getStructuredDataId() == structuredDataId) break;
//			}
			
			//_historyLocalService.addCRFHistory(subject.getName(), subjectId, subject.getSerialId(), sd.getPrimaryKey(), crfId, prevHistory.getCurrentJSON(), dataContent, 0, "1.0.0", crfHistoryServiceContext);
			//_queryLocalService.checkQuery(sd.getPrimaryKey(), crfForm, dataContent, subjectId, crfId, queryServiceContext);
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
