package ecrf.user.teeth.command.render;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCRenderCommand;
import com.liferay.portal.kernel.util.ParamUtil;

import java.util.List;

import javax.portlet.PortletException;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;

import org.osgi.service.component.annotations.Component;

import ecrf.user.teeth.constants.ECRFTeethPortletKeys;
import teeth.model.TreatmentHistory;
import teeth.service.TreatmentHistoryLocalServiceUtil;


@Component(
		immediate = true,
		property = {
			"javax.portlet.name="+ ECRFTeethPortletKeys.ECRFTEETH,
			"mvc.command.name=/teeth/permanentTeethView"
		},
		service = MVCRenderCommand.class
	)
public class PermanentTeethViewRenderCommand implements MVCRenderCommand {

	@Override
	public String render(RenderRequest renderRequest, RenderResponse renderResponse) throws PortletException {
		long PatientID = ParamUtil.getLong(renderRequest, "PatientID");
		List<TreatmentHistory> HistoryList = TreatmentHistoryLocalServiceUtil.getPatientTreatmentList(PatientID);
		try
		{			
			// Only Permanent Teeth (11~18, 21~28, 31~38, 41~48)
			processTeethRange(renderRequest, PatientID, 11, 48);

			renderRequest.setAttribute("patientID", PatientID);
			renderRequest.setAttribute("HistoryList", HistoryList);
			
			return "/teeth/view/permanentTeethview.jsp";
		}
		catch(Exception e)
		{
			_log.info("Error During PermanentTeethViewRenderCommand!");
			e.printStackTrace();
			return null;
		}
	}

	private void processTeethRange(RenderRequest renderRequest, long PatientID, long from, long to)
	{
		for(long i = from; i <= to; i++)
		{
			List<TreatmentHistory> HT = TreatmentHistoryLocalServiceUtil.getPatientTreatmentListByTeethNum(PatientID, i);
			renderRequest.setAttribute("teeth" + i, HT);
	        _log.info("teeth" + i + " : " + HT);
			
		}
	}
	Log _log = LogFactoryUtil.getLog(TotalTeethViewRenderCommand.class);

}
