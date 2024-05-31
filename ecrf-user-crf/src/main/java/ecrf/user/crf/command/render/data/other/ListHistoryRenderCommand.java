package ecrf.user.crf.command.render.data.other;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCRenderCommand;

import java.util.Iterator;

import javax.portlet.MimeResponse.Copy;
import javax.portlet.MutableRenderParameters;
import javax.portlet.PortletException;
import javax.portlet.PortletURL;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserJspPaths;
import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.service.CRFHistoryLocalService;

@Component(
	    immediate = true,
	    property = {
	        "javax.portlet.name=" + ECRFUserPortletKeys.CRF,
	        "mvc.command.name=" + ECRFUserMVCCommand.RENDER_LIST_CRF_DATA_HISTORY,
	    },
	    service = MVCRenderCommand.class
	)
public class ListHistoryRenderCommand implements MVCRenderCommand{
	@Override
	public String render(RenderRequest renderRequest, RenderResponse renderResponse) throws PortletException{
		_log.info("Render History List");
				
		_log.info("start");

		_log.info("end");
		
		return ECRFUserJspPaths.JSP_CRF_DATA_LIST_HISTORY;
	}
	
	private Log _log = LogFactoryUtil.getLog(ListHistoryRenderCommand.class);
}
