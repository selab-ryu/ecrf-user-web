package ecrf.user.crf.command.action.data;

import com.liferay.document.library.kernel.model.DLFileEntry;
import com.liferay.document.library.kernel.model.DLFolder;
import com.liferay.document.library.kernel.model.DLFolderConstants;
import com.liferay.document.library.kernel.service.DLAppService;
import com.liferay.portal.kernel.exception.PortalException;
import com.liferay.portal.kernel.exception.SystemException;
import com.liferay.portal.kernel.json.JSONArray;
import com.liferay.portal.kernel.json.JSONFactoryUtil;
import com.liferay.portal.kernel.json.JSONObject;
import com.liferay.portal.kernel.portlet.PortletURLFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.BaseMVCActionCommand;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCActionCommand;
import com.liferay.portal.kernel.repository.model.FileEntry;
import com.liferay.portal.kernel.service.ServiceContext;
import com.liferay.portal.kernel.service.ServiceContextFactory;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.upload.FileItem;
import com.liferay.portal.kernel.upload.UploadPortletRequest;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.PortalUtil;
import com.liferay.portal.kernel.util.WebKeys;
import com.liferay.portal.kernel.workflow.WorkflowConstants;
import com.sx.icecap.constant.IcecapDataTypeAttributes;
import com.sx.icecap.constant.IcecapWebKeys;
import com.sx.icecap.model.DataType;
import com.sx.icecap.model.StructuredData;
import com.sx.icecap.service.DataTypeLocalService;

import java.io.InputStream;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

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
	private static long DEFAULT_PARENT_FOLDER_ID = DLFolderConstants.DEFAULT_PARENT_FOLDER_ID;
	
	@Reference
	DLAppService _dlAppService;
	
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
		
		if(!isUpdate) {
			StructuredData sd = _dataTypeLocalService.addStructuredData(0, dataTypeId, dataContent, WorkflowConstants.STATUS_APPROVED, dataTypeServiceContext);
			UploadPortletRequest uploadPortletRequest = PortalUtil.getUploadPortletRequest(actionRequest);
			Map<String, FileItem[]> uploadFileMap= uploadPortletRequest.getMultipartParameterMap();
			Set<Entry<String, FileItem[]>> entrySet = uploadFileMap.entrySet();
			int result = 0; //means success

			for( Entry<String, FileItem[]> fileEntry : entrySet ){
				FileItem item[] = fileEntry.getValue();
				if( item.length == 0 ) {
					continue;
				}
				
				ServiceContext dlFolderSC = ServiceContextFactory.getInstance( DLFolder.class.getName(), actionRequest );
				DataType dataType = _dataTypeLocalService.getDataType(dataTypeId);
				String termName = item[0].getFieldName().split("_")[0];
				JSONObject termInfo = getTerm(termName, dataTypeId);
				
				long dataFileFolderId = _dataTypeLocalService.getDataFileFolderId(
						themeDisplay.getScopeGroupId(),
						DEFAULT_PARENT_FOLDER_ID,
						dataType.getDataTypeName(),
						dataType.getDataTypeVersion(),
						sd.getStructuredDataId(),
						termName,
						termInfo.getString("termVersion"),
						dlFolderSC,
						true);
				
				JSONObject jsonFiles = JSONFactoryUtil.createJSONObject();
				FileItem[] fileItems = fileEntry.getValue();
				for( FileItem fileItem : fileItems ) {
					if( fileItem.getSize() == 0 ) {
						continue;
					}
					
					String title = fileItem.getFileName();
					
					InputStream inputStream = fileItem.getInputStream();
					String description = "";
					long repositoryId = themeDisplay.getScopeGroupId();
					String mimeType = fileItem.getContentType();
					
					JSONObject jsonFile = JSONFactoryUtil.createJSONObject();
					try {
						ServiceContext fileServiceContext = ServiceContextFactory.getInstance( DLFileEntry.class.getName(), actionRequest );
						FileEntry addedFile = _dlAppService.addFileEntry(repositoryId, dataFileFolderId, title, mimeType, title, description, "", inputStream, fileItem.getSize(), fileServiceContext);
						
						jsonFile.put( "parentFolderId", dataFileFolderId );
						jsonFile.put( "fileId", addedFile.getFileEntryId() );
						jsonFile.put( "name", addedFile.getFileName() );
						jsonFile.put( "type", addedFile.getMimeType() );
						jsonFile.put( "size", addedFile.getSize() );
						
						jsonFiles.put( addedFile.getFileName(), jsonFile );
					} catch( PortalException e ) {
						result = 2; // means duplicated
						
						FileEntry dupFile = _dlAppService.getFileEntry(themeDisplay.getScopeGroupId(), dataFileFolderId, title);
						jsonFile.put( "parentFolderId", dataFileFolderId );
						jsonFile.put( "name", dupFile.getFileName() );
						jsonFile.put( "fileId", dupFile.getFileEntryId() );
						jsonFile.put( "type", dupFile.getMimeType() );
						jsonFile.put( "size", dupFile.getSize() );
						
						
						jsonFiles.put( dupFile.getFileName(), jsonFile );
						
					} catch( SystemException e ) {
						result = 1;
					}
					
					answer.put(termName, jsonFiles);
					System.out.println(answer.getJSONObject(termName));
					if( result == 1 ) {
						break;
					}
				}
				dataContent = answer.toJSONString();
				//TODO: need folderId set function
				_dataTypeLocalService.updateStructuredData(sd.getStructuredDataId(), 0, dataTypeId, dataContent, WorkflowConstants.STATUS_APPROVED, dataTypeServiceContext);
			}
			
			_linkCRFLocalService.addLinkCRF(subjectId, crfId, sd.getStructuredDataId(), linkServiceContext);
			_historyLocalService.addCRFHistory(subject.getName(), subjectId, subject.getSerialId(), sd.getPrimaryKey(), crfId, "", dataContent, 0, "1.0.0", crfHistoryServiceContext);
			_queryLocalService.checkQuery(sd.getPrimaryKey(), _dataTypeLocalService.getDataTypeStructureJSONObject(dataTypeId).getJSONArray("terms"), JSONFactoryUtil.createJSONObject(dataContent), subjectId, crfId, queryServiceContext);
		}
		else {
			// crf history by subject id & crf id
					
			StructuredData sd =	_dataTypeLocalService.updateStructuredData(structuredDataId, 0, dataTypeId, dataContent, WorkflowConstants.STATUS_APPROVED, dataTypeServiceContext);
			List<CRFHistory> prevHistoryList = _historyLocalService.getCRFHistoryByG_S_C_SD(themeDisplay.getScopeGroupId(), subjectId, crfId, structuredDataId);
			CRFHistory prevHistory = prevHistoryList.get(0);

			_historyLocalService.addCRFHistory(subject.getName(), subjectId, subject.getSerialId(), sd.getPrimaryKey(), crfId, prevHistory.getCurrentJSON(), dataContent, 0, "1.0.0", crfHistoryServiceContext);
			_queryLocalService.checkQuery(sd.getPrimaryKey(), _dataTypeLocalService.getDataTypeStructureJSONObject(dataTypeId).getJSONArray("terms"), JSONFactoryUtil.createJSONObject(dataContent), subjectId, crfId, queryServiceContext);
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
	
	private Boolean isFileTerm(String termName, long dataTypeId) {
		JSONArray crfForm = null;
		try {
			 crfForm = _dataTypeLocalService.getDataTypeStructureJSONObject(dataTypeId).getJSONArray("terms");
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		for(int i = 0; i < crfForm.length(); i++) {
			if(crfForm.getJSONObject(i).getString("termType").equals("File")) {
				if(termName.equals(crfForm.getJSONObject(i).getString("termName"))) {
					System.out.println("find File");
					return true;
				}
			}
		}
		
		return false;
	}
	
	private JSONObject getTerm(String termName, long dataTypeId) {
		JSONArray crfForm = null;
		try {
			 crfForm = _dataTypeLocalService.getDataTypeStructureJSONObject(dataTypeId).getJSONArray("terms");
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		for(int i = 0; i < crfForm.length(); i++) {
			if(termName.equals(crfForm.getJSONObject(i).getString("termName"))) {	
				return crfForm.getJSONObject(i);
			}
		}
		
		return null;
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
