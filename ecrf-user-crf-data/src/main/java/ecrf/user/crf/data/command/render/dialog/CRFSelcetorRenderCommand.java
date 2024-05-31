package ecrf.user.crf.data.command.render.dialog;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCRenderCommand;
import com.liferay.portal.kernel.servlet.SessionErrors;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.Validator;
import com.sx.icecap.exception.NoSuchDataTypeException;
import com.sx.icecap.model.DataType;
import com.sx.icecap.model.StructuredData;
import com.sx.icecap.service.DataTypeLocalService;
import com.sx.icecap.service.StructuredDataLocalService;

import java.util.ArrayList;
import java.util.List;

import javax.portlet.PortletException;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserJspPaths;
import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.constants.attribute.ECRFUserCRFDataAttributes;
import ecrf.user.constants.attribute.ECRFUserCRFSubjectInfoAttribute;
import ecrf.user.model.CRFSubject;
import ecrf.user.model.LinkCRF;
import ecrf.user.service.CRFLocalService;
import ecrf.user.service.CRFSubjectLocalService;
import ecrf.user.service.LinkCRFLocalService;

@Component(
    immediate = true,
    property = {
        "javax.portlet.name=" + ECRFUserPortletKeys.CRF_DATA,
        "mvc.command.name=" + ECRFUserMVCCommand.RENDER_DIALOG_CRF,
    },
    service = MVCRenderCommand.class
)
public class CRFSelcetorRenderCommand implements MVCRenderCommand {
	@Override
	public String render(RenderRequest renderRequest, RenderResponse renderResponse) throws PortletException {
		_log.info("Render CRF Selector");

		long crfId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.CRF_ID, 0);
		long subjectId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.SUBJECT_ID, 0);
		
		List<LinkCRF> links = _linkLocalService.getLinkCRFByC_S(crfId, subjectId);
		_log.info("link size : " + links.size());

		ArrayList<LinkCRF> linkList = new ArrayList<>();
		for(int i = 0; i < links.size(); i++) {
			if(Validator.isNotNull(links.get(i).getStructuredDataId())) {
				linkList.add(links.get(i));
			}
		}
  
	    // check crf-subject update lock
	    boolean updateLock = false;
	
	    CRFSubject crfSubject = null;
	    if(crfId > 0 && subjectId > 0) {
	    	crfSubject = _crfSubjectLocalService.getCRFSubjectByC_S(crfId, subjectId);
			if(Validator.isNotNull(crfSubject)) {
				updateLock = crfSubject.getUpdateLock();
			}
		}
		
		// check crf has crf-form
		boolean hasForm = false;
		
		long dataTypeId = _crfLocalService.getDataTypeId(crfId);
		if(dataTypeId > 0) {
			DataType dataType = null;
			try {
				dataType = _dataTypeLocalService.getDataType(dataTypeId);
			} catch (Exception e) {
				if(e instanceof NoSuchDataTypeException) {
					SessionErrors.add(renderRequest, e.getClass());
				} else {
					e.printStackTrace();
				}
			}
			
			hasForm = dataType.getHasDataStructure();
			_log.info("has form : " + hasForm);
		}
		
		renderRequest.setAttribute(ECRFUserCRFDataAttributes.HAS_FORM, hasForm);
	    renderRequest.setAttribute(ECRFUserCRFDataAttributes.STRUCTURED_DATA_LIST, linkList);
	    renderRequest.setAttribute(ECRFUserCRFSubjectInfoAttribute.UPDATE_LOCK, updateLock);
			
		return ECRFUserJspPaths.JSP_DIALOG_CRF_DATA_VERSION;
	}
	
	private Log _log = LogFactoryUtil.getLog(CRFSelcetorRenderCommand.class);
	
	@Reference
	private LinkCRFLocalService _linkLocalService;
	
	@Reference
	private DataTypeLocalService _dataTypeLocalService;
	
	@Reference
	private StructuredDataLocalService	_structuredDataLocalService;
	
	@Reference
	private CRFLocalService _crfLocalService;
	
	@Reference
	private CRFSubjectLocalService _crfSubjectLocalService;
}
