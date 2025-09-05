package ecrf.user.teeth.command.render;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCRenderCommand;
import com.liferay.portal.kernel.util.ParamUtil;

import javax.portlet.PortletException;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;

import org.osgi.service.component.annotations.Component;

import ecrf.user.teeth.constants.ECRFTeethPortletKeys;


@Component(
		immediate = true,
		property = {
			"javax.portlet.name="+ ECRFTeethPortletKeys.ECRFTEETH,
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
		renderRequest.setAttribute("teeths", result);
		
		return "/teeth/add/addteeth.jsp";
	}
	
	private Log _log = LogFactoryUtil.getLog(AddTreatmentDialogRenderCommand.class);

}
