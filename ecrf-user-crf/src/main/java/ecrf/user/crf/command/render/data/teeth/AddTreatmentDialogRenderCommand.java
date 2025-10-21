package ecrf.user.crf.command.render.data.teeth;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCRenderCommand;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.WebKeys;

import javax.portlet.PortletException;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.constants.attribute.ECRFUserCRFDataAttributes;
import ecrf.user.model.Subject;
import ecrf.user.service.SubjectLocalService;


@Component(
		immediate = true,
		property = {
			"javax.portlet.name="+ ECRFUserPortletKeys.CRF,
			"mvc.command.name=/render/add_tooth_treatment"
		},
		service = MVCRenderCommand.class
	)
public class AddTreatmentDialogRenderCommand implements MVCRenderCommand {

	@Override
	public String render(RenderRequest renderRequest, RenderResponse renderResponse) throws PortletException {
		String teethArrStr = ParamUtil.getString(renderRequest, "teeths");
				
		String result = teethArrStr.replaceAll("[^0-9,]", "");
		
		_log.info(teethArrStr);
		_log.info(result);

		ThemeDisplay themeDisplay = (ThemeDisplay)renderRequest.getAttribute(WebKeys.THEME_DISPLAY);
		long groupId = themeDisplay.getScopeGroupId();

		long subjectId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.SUBJECT_ID, 0);
		long crfId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.CRF_ID, 0);
		long linkId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.LINK_ID, 0);
		
		if(subjectId > 0) {
			try {
				Subject subject = _subjectLocalService.getSubject(subjectId);
				renderRequest.setAttribute(ECRFUserCRFDataAttributes.SUBJECT, subject);
			} catch (Exception e) {
				_log.error(e.getMessage());
			}
		}
		
		_log.info(groupId + " / " + crfId + " / " + subjectId + " / " + linkId);

		renderRequest.setAttribute("teeths", result);
		
		return "/html/crf-data/teeth/add-teeth.jsp";
	}

	@Reference
	private SubjectLocalService _subjectLocalService;
	
	private Log _log = LogFactoryUtil.getLog(AddTreatmentDialogRenderCommand.class);
}

