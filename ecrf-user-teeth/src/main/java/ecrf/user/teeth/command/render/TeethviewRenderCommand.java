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

import ecrf.user.constants.attribute.ECRFUserTeethAttributes;
import ecrf.user.teeth.constants.ECRFTeethPortletKeys;
import teeth.model.TreatmentHistory;
import teeth.service.TreatmentHistoryLocalServiceUtil;

@Component(
		immediate = true,
		property = {
			"javax.portlet.name="+ ECRFTeethPortletKeys.ECRFTEETH,
			"mvc.command.name=/teeth/teethView"
		},
		service = MVCRenderCommand.class
	)
public class TeethviewRenderCommand implements MVCRenderCommand {

	@Override
	public String render(RenderRequest renderRequest, RenderResponse renderResponse) throws PortletException {
		long PatientID = 1001; // Temporal PatientID
		List<TreatmentHistory> HistoryList = TreatmentHistoryLocalServiceUtil.getPatientTreatmentList(PatientID);
		
		long crfId = ParamUtil.getLong(renderRequest, ECRFUserTeethAttributes.CRF_ID);
		long subjectId = ParamUtil.getLong(renderRequest, ECRFUserTeethAttributes.SUBJECT_ID);
		long linkId = ParamUtil.getLong(renderRequest, ECRFUserTeethAttributes.LINK_ID);
		
		// get treatment list by link id (it has crf id, subject id, sd id) 
		
		// how to handle permanent, deciduous teeth
		// if permanent treatment is exist, process to full teeth page
		// otherwise process to deciduous teeth page
		
		// check permanent teeth treatment
		boolean isPermanent = false;
		try
		{
			// Permanent (11~18, 21~28, 31~38, 41~48) checkPermanent=true
			processTeethRange(renderRequest, PatientID, 11, 48, true, isPermanent);

			// Deciduous (51~55, 61~65, 71~75, 81~85) checkPermaenet=false
			processTeethRange(renderRequest, PatientID, 51, 85, false, isPermanent);
			
			renderRequest.setAttribute("patientID", PatientID);
			renderRequest.setAttribute("HistoryList", HistoryList);
			
			if(isPermanent == true)
			{
				return "/teeth/view/permanentTeethview.jsp";
			}
			else
			{
				return "/teeth/view/deciduousTeethview.jsp";
			}
		}
		catch(Exception e)
		{
			_log.info("Error During TeethView!");
		}
		
		
		return null;
	}
	
	private void processTeethRange(RenderRequest renderRequest, long PatientID, long from, long to, boolean checkPermanent, boolean isPermanent)
	{
		for(long i = from; i <= to; i++)
		{
			List<TreatmentHistory> HT = TreatmentHistoryLocalServiceUtil.getPatientTreatmentListByTeethNum(PatientID, i);
			if (checkPermanent && !HT.isEmpty()) 
			{
				isPermanent = true;
			}
			renderRequest.setAttribute("teeth" + i, HT);
			
		}
	}
	Log _log = LogFactoryUtil.getLog(TeethviewRenderCommand.class);
}
