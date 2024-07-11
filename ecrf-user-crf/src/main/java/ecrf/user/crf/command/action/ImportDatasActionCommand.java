package ecrf.user.crf.command.action;

import com.liferay.portal.kernel.json.JSONArray;
import com.liferay.portal.kernel.json.JSONFactoryUtil;
import com.liferay.portal.kernel.json.JSONObject;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.model.Company;
import com.liferay.portal.kernel.portlet.PortletURLFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.BaseMVCActionCommand;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCActionCommand;
import com.liferay.portal.kernel.service.ServiceContext;
import com.liferay.portal.kernel.service.ServiceContextFactory;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.upload.UploadPortletRequest;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.Portal;
import com.liferay.portal.kernel.util.PortalUtil;
import com.liferay.portal.kernel.util.Validator;
import com.liferay.portal.kernel.util.WebKeys;
import com.liferay.portal.kernel.workflow.WorkflowConstants;
import com.sx.icecap.model.DataType;
import com.sx.icecap.model.StructuredData;
import com.sx.icecap.service.DataTypeLocalService;

import java.io.File;
import java.nio.file.Files;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import javax.portlet.ActionRequest;
import javax.portlet.ActionResponse;
import javax.portlet.PortletRequest;
import javax.portlet.PortletURL;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.constants.ECRFUserWebKeys;
import ecrf.user.constants.attribute.ECRFUserCRFAttributes;
import ecrf.user.model.CRFAutoquery;
import ecrf.user.model.CRFHistory;
import ecrf.user.model.LinkCRF;
import ecrf.user.model.Subject;
import ecrf.user.service.CRFAutoqueryLocalService;
import ecrf.user.service.CRFHistoryLocalService;
import ecrf.user.service.LinkCRFLocalService;
import ecrf.user.service.SubjectLocalService;

@Component(
	    immediate = true,
	    property = {
	        "javax.portlet.name=" + ECRFUserPortletKeys.CRF,
	        "mvc.command.name="+ECRFUserMVCCommand.ACTION_IMPORT_DATAS	        
	    },
	    service = MVCActionCommand.class
	)
public class ImportDatasActionCommand extends BaseMVCActionCommand{

	@Override
	protected void doProcessAction(ActionRequest actionRequest, ActionResponse actionResponse) throws Exception {
		System.out.println("Import Datas Start");
		
		long crfId = ParamUtil.getLong(actionRequest, ECRFUserCRFAttributes.CRF_ID);
		long dataTypeId = ParamUtil.getLong(actionRequest, ECRFUserCRFAttributes.DATATYPE_ID);
		System.out.println(crfId + ", " + dataTypeId);
		
		UploadPortletRequest uploadPortletRequest = PortalUtil.getUploadPortletRequest(actionRequest);
		
		File file = uploadPortletRequest.getFile("jsonInput");
		
		String json = new String(Files.readAllBytes(file.toPath()));
		JSONArray jsonArray = JSONFactoryUtil.createJSONArray(json);
		
		HttpServletRequest httpServletRequest = _portal.getHttpServletRequest(actionRequest);
		HttpSession session = httpServletRequest.getSession();
		ThemeDisplay themeDisplay = (ThemeDisplay)actionRequest.getAttribute(WebKeys.THEME_DISPLAY);
		Company company = themeDisplay.getCompany();
		
		ServiceContext linkServiceContext = ServiceContextFactory.getInstance(LinkCRF.class.getName(), actionRequest);
		ServiceContext dataTypeServiceContext = ServiceContextFactory.getInstance(DataType.class.getName(), actionRequest);
		ServiceContext crfHistoryServiceContext = ServiceContextFactory.getInstance(CRFHistory.class.getName(), actionRequest);
		
		ServiceContext subjectServiceContext = ServiceContextFactory.getInstance(Subject.class.getName(), actionRequest);
		ServiceContext queryServiceContext = ServiceContextFactory.getInstance(CRFAutoquery.class.getName(), actionRequest);
		
		for(int i = 0; i < jsonArray.length(); i++) {
			if(jsonArray.getJSONObject(i).has("visit_date")) {
				String serialId = jsonArray.getJSONObject(i).getString("ID");
				jsonArray.getJSONObject(i).remove("ID");
				JSONObject answerForm = jsonArray.getJSONObject(i);
				Iterator<String> keys = answerForm.keys();
				ArrayList<String> deleteKeys = new ArrayList<String>();
				
				while(keys.hasNext()) {
					String key = keys.next();
					if(answerForm.getString(key).equals("") || answerForm.getString(key).equals("[]")) {
						deleteKeys.add(key);
					}
				}
				
				for(String deleteKey : deleteKeys) {
					answerForm.remove(deleteKey);
				}

				Subject subject = _subjectLocalService.getSubjectBySerialId(serialId);
				if(Validator.isNotNull(subject)) {
					List<LinkCRF> linkList = _linkLocalService.getLinkCRFByC_S(crfId, subject.getSubjectId());
					if(linkList.size() > 0) {
						for(int j = 0; j < linkList.size(); j++) {
							long sdId = linkList.get(j).getStructuredDataId();
							JSONObject compareSd = JSONFactoryUtil.createJSONObject(_dataTypeLocalService.getStructuredData(sdId));
							if(compareSd.getString("visit_date").equals(answerForm.getString("visit_date"))){
								_dataTypeLocalService.updateStructuredData(sdId, 0, dataTypeId, answerForm.toJSONString(), WorkflowConstants.STATUS_APPROVED, dataTypeServiceContext);
								
								List<CRFHistory> prevHistoryList = _historyLocalService.getCRFHistoryByC_S(crfId, subject.getSubjectId());

								CRFHistory prevHistory = prevHistoryList.get(prevHistoryList.size() - 1);
								for(int k = prevHistoryList.size() - 1; k > -1; k--) {
									prevHistory = prevHistoryList.get(k);
									if(prevHistory.getStructuredDataId() == sdId) break;
								}
								
								_historyLocalService.addCRFHistory(subject.getName(), subject.getSubjectId(), subject.getSerialId(), sdId, crfId, prevHistory.getCurrentJSON(), answerForm.toJSONString(), 0, "1.0.0", crfHistoryServiceContext);
								_queryLocalService.checkQuery(sdId, _dataTypeLocalService.getDataTypeStructureJSONObject(dataTypeId).getJSONArray("terms"), answerForm, subject.getSubjectId(), crfId, queryServiceContext);
							}
							
						}
					}else {
						StructuredData storedData = _dataTypeLocalService.addStructuredData(0, dataTypeId, answerForm.toJSONString(), WorkflowConstants.STATUS_APPROVED, dataTypeServiceContext);
						_linkLocalService.addLinkCRF(subject.getSubjectId(), crfId, storedData.getStructuredDataId(), linkServiceContext);
						_historyLocalService.addCRFHistory(subject.getName(), subject.getSubjectId(), subject.getSerialId(), storedData.getPrimaryKey(), crfId, "", answerForm.toJSONString(), 0, "1.0.0", crfHistoryServiceContext);
						_queryLocalService.checkQuery(storedData.getPrimaryKey(), _dataTypeLocalService.getDataTypeStructureJSONObject(dataTypeId).getJSONArray("terms"), answerForm, subject.getSubjectId(), crfId, queryServiceContext);
					}
				}
			}else {
				System.out.println("Wrong file input");
			}
		}
		
		PortletURL renderURL = PortletURLFactoryUtil.create(
				actionRequest, 
				themeDisplay.getPortletDisplay().getId(), 
				themeDisplay.getPlid(),
				PortletRequest.RENDER_PHASE);
		renderURL.setParameter(ECRFUserCRFAttributes.CRF_ID, String.valueOf(crfId));
		renderURL.setParameter(ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME, ECRFUserMVCCommand.RENDER_UPDATE_CRF);
		
		actionResponse.sendRedirect(renderURL.toString());
		
	}
	
	@Reference
	private SubjectLocalService _subjectLocalService;
	
	@Reference
	private LinkCRFLocalService _linkLocalService;
	
	@Reference
	private DataTypeLocalService _dataTypeLocalService;
	
	@Reference
	private CRFHistoryLocalService _historyLocalService;
	
	@Reference
	private CRFAutoqueryLocalService _queryLocalService;

	@Reference
	private Portal _portal;
	
	private Log _log;
}