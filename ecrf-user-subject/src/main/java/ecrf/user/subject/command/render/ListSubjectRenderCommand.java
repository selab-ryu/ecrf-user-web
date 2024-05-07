/**
 * 
 */
package ecrf.user.subject.command.render;

import com.liferay.petra.string.StringPool;
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

import ecrf.user.constants.ECRFUserConstants;
import ecrf.user.constants.ECRFUserJspPaths;
import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.service.SubjectLocalService;

/**
 * @author SELab-Ryu
 *
 */
@Component(
	property = {
		"javax.portlet.name="+ECRFUserPortletKeys.SUBJECT,
		"mvc.command.name="+ECRFUserMVCCommand.RENDER_LIST_SUBJECT	
	},
	service=MVCRenderCommand.class
)
public class ListSubjectRenderCommand implements MVCRenderCommand {
	private Log _log = LogFactoryUtil.getLog(ListSubjectRenderCommand.class);
	
	@Override
	public String render(RenderRequest renderRequest, RenderResponse renderResponse) throws PortletException {
		
		String cmd = ParamUtil.getString(renderRequest, Constants.CMD, StringPool.BLANK);
		
		String listPath = StringPool.BLANK;
		
		_log.info(listPath);
		
		if(cmd.equals(Constants.UPDATE)) {
			listPath = ECRFUserJspPaths.JSP_LIST_SUBJECT_UPDATE;
		} else if(cmd.equals(Constants.DELETE)) {
			listPath = ECRFUserJspPaths.JSP_LIST_SUBJECT_DELETE;
		} else {
			listPath = ECRFUserJspPaths.JSP_LIST_SUBJECT;
		}
		
		renderRequest.setAttribute(ECRFUserConstants.SUBJECT_LOCAL_SERVICE, _subjectLocalService);
		
		return listPath;
	}
	
	@Reference
	private SubjectLocalService _subjectLocalService;
}
