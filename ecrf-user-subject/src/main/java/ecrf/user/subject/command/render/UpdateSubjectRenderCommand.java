/**
 * 
 */
package ecrf.user.subject.command.render;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCRenderCommand;
import com.liferay.portal.kernel.util.Constants;
import com.liferay.portal.kernel.util.ParamUtil;

import javax.portlet.PortletException;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserJspPaths;
import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.constants.attribute.ECRFUserSubjectAttributes;
import ecrf.user.model.Subject;
import ecrf.user.service.SubjectLocalService;

/**
 * @author SELab-Ryu
 *
 */
@Component(
	property = {
		"javax.portlet.name="+ECRFUserPortletKeys.SUBJECT,
		"mvc.command.name="+ECRFUserMVCCommand.RENDER_UPDATE_SUBJECT
	},
	service=MVCRenderCommand.class
)
public class UpdateSubjectRenderCommand implements MVCRenderCommand {

	@Override
	public String render(RenderRequest renderRequest, RenderResponse renderResponse) throws PortletException {
		_log = LogFactoryUtil.getLog(this.getClass().getName());
		
		long subjectId = ParamUtil.getLong(renderRequest, ECRFUserSubjectAttributes.SUBJECT_ID, 0);
		
		_log.info("subject id : " + subjectId);
		
		Subject subject = null;
		if(subjectId > 0) {
			try {
				subject = _subjectLocalService.getSubject(subjectId);
				_log.info("birth : " + subject.getBirth());
			} catch (Exception e) {
				throw new PortletException("Cannot find subject : " + subjectId);
			}
			renderRequest.setAttribute(ECRFUserSubjectAttributes.SUBJECT, subject);
		}
		
		_log.info("End");
		
		return ECRFUserJspPaths.JSP_UPDATE_SUBJECT;
	}

	private Log _log;
	
	@Reference
	private SubjectLocalService _subjectLocalService;
}
