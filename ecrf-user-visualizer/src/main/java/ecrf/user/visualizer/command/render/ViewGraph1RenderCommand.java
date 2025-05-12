package ecrf.user.visualizer.command.render;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCRenderCommand;

import javax.portlet.PortletException;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;

import org.osgi.service.component.annotations.Component;

import ecrf.user.visualizer.constants.ECRFVisualizerJspPaths;
import ecrf.user.visualizer.constants.ECRFVisualizerMVCCommand;
import ecrf.user.visualizer.constants.ECRFVisualizerPortletKeys;

/**
 * @author dev-ryu
 *
 */

@Component(
    immediate = true,
    property = {
        "javax.portlet.name=" + ECRFVisualizerPortletKeys.ECRFVISUALIZER,
        "mvc.command.name="+ECRFVisualizerMVCCommand.RENDER_VIEW_GRAPH_1
    },
    service = MVCRenderCommand.class
)
public class ViewGraph1RenderCommand implements MVCRenderCommand {

	@Override
	public String render(RenderRequest renderRequest, RenderResponse renderResponse) throws PortletException {
		_log.info("move to graph1");
		
		return ECRFVisualizerJspPaths.GRAPH1;
	}
	
	private Log _log = LogFactoryUtil.getLog(ViewGraph1RenderCommand.class);

}
