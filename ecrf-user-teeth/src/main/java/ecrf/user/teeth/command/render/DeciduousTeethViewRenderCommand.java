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
			"mvc.command.name=/teeth/deciduousTeethView"
		},
		service = MVCRenderCommand.class
	)
public class DeciduousTeethViewRenderCommand implements MVCRenderCommand {

	@Override
	public String render(RenderRequest renderRequest, RenderResponse renderResponse) throws PortletException {
		// TODO Auto-generated method stub
		_log.info("Hello!");
		long PatientID = ParamUtil.getLong(renderRequest, "PatientID");
		List<TreatmentHistory> HistoryList = TreatmentHistoryLocalServiceUtil.getPatientTreatmentList(PatientID);
		try
		{
			// only deciduous teeth (51~55, 61~65, 71~75, 81~85)
			processTeethRange(renderRequest, PatientID, 51, 85);

			renderRequest.setAttribute("patientID", PatientID);
			renderRequest.setAttribute("HistoryList", HistoryList);
			
			return "/teeth/view/deciduousTeethview.jsp";
		}
		catch(Exception e)
		{
			_log.info("Error During DeciduousTeethView!");
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
		}
	}
	Log _log = LogFactoryUtil.getLog(DeciduousTeethViewRenderCommand.class);

}
