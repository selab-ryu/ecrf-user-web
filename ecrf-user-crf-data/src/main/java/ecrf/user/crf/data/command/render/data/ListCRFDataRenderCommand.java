package ecrf.user.crf.data.command.render.data;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCRenderCommand;
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
import ecrf.user.constants.ECRFUserWebKeys;

@Component(
    immediate = true,
    property = {
        "javax.portlet.name=" + ECRFUserPortletKeys.CRF_DATA,
        "mvc.command.name="+ECRFUserMVCCommand.RENDER_LIST_CRF_DATA
    },
    service = MVCRenderCommand.class
)
public class ListCRFDataRenderCommand implements MVCRenderCommand {

	@Override
	public String render(RenderRequest renderRequest, RenderResponse renderResponse) throws PortletException {
		_log.info("list crf data render command");
		
		String listPath = ParamUtil.getString(renderRequest, ECRFUserWebKeys.LIST_PATH, ECRFUserJspPaths.JSP_LIST_CRF_DATA);
				
		return listPath;
	}
		
	private Log _log = LogFactoryUtil.getLog(ListCRFDataRenderCommand.class);
}
