/**
 * 
 */
package ecrf.user.crf.command.render.dialog;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCRenderCommand;
import com.liferay.portal.kernel.util.ParamUtil;

import javax.portlet.PortletException;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;

import org.osgi.service.component.annotations.Component;

import ecrf.user.constants.ECRFUserJspPaths;
import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.constants.attribute.ECRFUserAttributes;
import ecrf.user.constants.attribute.ECRFUserCRFAttributes;

/**
 * @author SELab-Ryu
 *
 */

@Component(
	    immediate = true,
	    property = {
	        "javax.portlet.name=" + ECRFUserPortletKeys.CRF,
	        "mvc.command.name=" + ECRFUserMVCCommand.RENDER_DIALOG_CRF_SUBJECT,
	    },
	    service = MVCRenderCommand.class
	)
public class ManageCRFSubjectDialogRenderCommand implements MVCRenderCommand {
	private Log _log = LogFactoryUtil.getLog(ManageCRFSubjectDialogRenderCommand.class);
	
	@Override
	public String render(RenderRequest renderRequest, RenderResponse renderResponse) throws PortletException {
		_log.info("render manage crf subject dialog");
		
		long crfId = ParamUtil.getLong(renderRequest, ECRFUserCRFAttributes.CRF, 0);
		long groupId = ParamUtil.getLong(renderRequest, ECRFUserAttributes.GROUP_ID, 0);
		
		String crfSubjectInfoStr = (String) renderRequest.getAttribute("crfSubjectInfo");
		
		_log.info(crfSubjectInfoStr);
		
		return ECRFUserJspPaths.JSP_DIALOG_MANAGE_CRF_SUBJECT;
	}

}
