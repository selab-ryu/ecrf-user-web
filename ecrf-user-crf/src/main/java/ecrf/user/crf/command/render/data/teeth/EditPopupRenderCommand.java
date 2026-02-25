package ecrf.user.crf.command.render.data.teeth;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCRenderCommand;
import com.liferay.portal.kernel.util.ParamUtil;

import java.util.ArrayList;
import java.util.List;

import javax.portlet.PortletException;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserPortletKeys;
import teeth.model.TreatmentHistory;
import teeth.service.TreatmentHistoryLocalService;
import teeth.service.TreatmentHistoryLocalServiceUtil;


@Component(
	immediate = true,
	property = {
		"javax.portlet.name=" + ECRFUserPortletKeys.CRF,
		"mvc.command.name=/teeth/editHistoryPopup"
	},
	service = MVCRenderCommand.class
)
public class EditPopupRenderCommand implements MVCRenderCommand {

	@Override
	public String render(RenderRequest renderRequest, RenderResponse renderResponse) throws PortletException {
		long treatmentId = ParamUtil.getLong(renderRequest, "treatmentId");
		TreatmentHistory treatmentHistory = null;

		if(treatmentId > 0) {
			try {
				treatmentHistory = _treatmentHistoryLocalService.getTreatmentHistory(treatmentId);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		
		renderRequest.setAttribute("treatmentHistory", treatmentHistory);

		return "/html/crf-data/teeth/edit-history-popup.jsp";
	}

	@Reference
	private TreatmentHistoryLocalService _treatmentHistoryLocalService;

	Log _log = LogFactoryUtil.getLog(EditPopupRenderCommand.class);
}
