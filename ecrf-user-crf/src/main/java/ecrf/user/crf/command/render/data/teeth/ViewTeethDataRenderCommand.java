package ecrf.user.crf.command.render.data.teeth;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCRenderCommand;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.WebKeys;
import com.sx.icecap.service.DataTypeLocalService;

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
import ecrf.user.model.CRF;
import ecrf.user.model.LinkCRF;
import ecrf.user.model.Subject;
import ecrf.user.service.CRFLocalService;
import ecrf.user.service.LinkCRFLocalService;
import ecrf.user.service.SubjectLocalService;
import teeth.model.TreatmentHistory;
import teeth.service.TreatmentHistoryLocalService;


@Component(
	    immediate = true,
	    property = {
	        "javax.portlet.name=" + ECRFUserPortletKeys.CRF,
	        "mvc.command.name=" + ECRFUserMVCCommand.RENDER_VIEW_TEETH_DATA
	    },
	    service = MVCRenderCommand.class
	)


public class ViewTeethDataRenderCommand implements MVCRenderCommand {
	@Override
	public String render(RenderRequest renderRequest, RenderResponse renderResponse) throws PortletException {
		System.out.println("Render CRF View");
		
		ThemeDisplay themeDisplay = (ThemeDisplay)renderRequest.getAttribute(WebKeys.THEME_DISPLAY);
		long groupId = themeDisplay.getScopeGroupId();
				
		long subjectId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.SUBJECT_ID, 0);
		long crfId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.CRF_ID, 0);
		long linkId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.LINK_ID, 0);
				
		_log.info("s / c / link : " + subjectId + " / " + crfId + " / " + linkId);
		
		Subject subject = null;
		LinkCRF linkCRF = null;
		
		CRF crf = null;
		long dataTypeId = 0;
			
		try {
			if(subjectId > 0) {
				subject = _subjectLocalService.getSubject(subjectId);
				renderRequest.setAttribute(ECRFUserCRFDataAttributes.SUBJECT_ID, subjectId);
				
				if(linkId > 0) {
					linkCRF = _linkCRFLocalService.getLinkCRF(linkId);
					renderRequest.setAttribute(ECRFUserCRFDataAttributes.LINK_ID, linkId);
				}
				
				int crfDataCount = _linkCRFLocalService.countLinkCRFByG_S_C(groupId, subjectId, crfId);
			}	
		
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		// get crf & dataType id
		try {
			crf = _crfLocalService.getCRF(crfId);
			dataTypeId = crf.getDatatypeId();
		} catch (Exception crfEx) {
			throw new PortletException("Cannot find subject : " + crfId);
		}
				
		renderRequest.setAttribute(ECRFUserCRFDataAttributes.SUBJECT, subject);
		renderRequest.setAttribute("SubjectLocalService", _subjectLocalService);
		renderRequest.setAttribute(ECRFUserCRFDataAttributes.LINK_CRF, linkCRF);
		renderRequest.setAttribute("LinkCRFLocalService", _linkCRFLocalService);
		
		renderRequest.setAttribute(ECRFUserCRFDataAttributes.CRF_ID, crfId);
		
		List<TreatmentHistory> HistoryList = _treatmentHisotryLocalService.getTreatmentsByG_C_P_L(groupId, crfId, subjectId, linkId);
		
		boolean isPermanent = false;
		try
		{
			// Permanent (11~18, 21~28, 31~38, 41~48) checkPermanent=true
			processTeethRange(renderRequest, groupId, crfId, subjectId, linkId, 11, 48, true, isPermanent);

			// Deciduous (51~55, 61~65, 71~75, 81~85) checkPermaenet=false
			processTeethRange(renderRequest, groupId, crfId, subjectId, linkId, 51, 85, false, isPermanent);
			
			renderRequest.setAttribute("HistoryList", HistoryList);
		}
		catch(Exception e)
		{
			_log.info("Error During TeethView!");
		}
		
		return ECRFUserJspPaths.JSP_VIEW_TEETH_DATA;
	}
	
	private void processTeethRange(RenderRequest renderRequest, long groupId, long crfId, long patientID, long linkId, long from, long to, boolean checkPermanent, boolean isPermanent)
	{
		for(long i = from; i <= to; i++)
		{
			List<TreatmentHistory> HT = _treatmentHisotryLocalService.getTreatmentsByG_C_P_L_TN(groupId, crfId, patientID, linkId, i);
			if (checkPermanent && !HT.isEmpty()) 
			{
				isPermanent = true;
			}
			renderRequest.setAttribute("teeth" + i, HT);
		}
	}

	private Log _log = LogFactoryUtil.getLog(ViewTeethDataRenderCommand.class);
	
	@Reference
	private SubjectLocalService _subjectLocalService;
	
	@Reference
	private CRFLocalService _crfLocalService;
	
	@Reference
	private LinkCRFLocalService _linkCRFLocalService;

	@Reference
	private DataTypeLocalService _dataTypeLocalService;
	
	@Reference
	private TreatmentHistoryLocalService _treatmentHisotryLocalService;

}
