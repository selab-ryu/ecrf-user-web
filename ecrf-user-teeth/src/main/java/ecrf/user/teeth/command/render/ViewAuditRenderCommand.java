package ecrf.user.teeth.command.render;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCRenderCommand;
import com.liferay.portal.kernel.util.ParamUtil;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

import javax.portlet.PortletException;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;

import org.osgi.service.component.annotations.Component;

import ecrf.user.teeth.constants.ECRFTeethPortletKeys;
import teeth.model.TreatmentAudit;
import teeth.service.TreatmentAuditLocalServiceUtil;


@Component(
       immediate = true,
       property = {
           "javax.portlet.name=" + ECRFTeethPortletKeys.ECRFTEETH,
           "mvc.command.name=/teeth/viewAuditTrail"
       },
       service = MVCRenderCommand.class
   )
public class ViewAuditRenderCommand implements MVCRenderCommand {

   @Override
   public String render(RenderRequest renderRequest, RenderResponse renderResponse) throws PortletException {
      // TODO Auto-generated method stub
      
      String mode = ParamUtil.getString(renderRequest, "mode");
      _log.info("mode: " + mode);
      
      List<TreatmentAudit> DisplayList = new ArrayList<>();
      
      if(mode.equals("All"))
      {
         DisplayList = TreatmentAuditLocalServiceUtil.getTreatmentAudits(-1, -1);
      }
      else if(mode.equals("Teeth"))
      {
         long TeethNum = ParamUtil.getLong(renderRequest, "teethNum");
         _log.info("Teeth: " + TeethNum);
         DisplayList = TreatmentAuditLocalServiceUtil.getAuditByTeethNum(TeethNum);
         renderRequest.setAttribute("teethNum", TeethNum); 
      }
      else if(mode.equals("deciduous")) {
    	    long[] decidiousTeethNums = 
    	    	{
	    			51L, 52L, 53L, 54L, 55L,
	    			61L, 62L, 63L, 64L, 65L,
	    			71L, 72L, 73L, 74L, 75L,
	    			81L, 82L, 83L, 84L, 85L,
	    		};
    	    for (long teethNum : decidiousTeethNums) {
    	        DisplayList.addAll(TreatmentAuditLocalServiceUtil.getAuditByTeethNum(teethNum));
    	    }
      }
      else if(mode.equals("permanent")) {
  	    long[] permanentTeethNums = 
  	    	{
	    			11L, 12L, 13L, 14L, 15L, 16L, 17L, 18L,
	    			21L, 22L, 23L, 24L, 25L, 26L, 27L, 28L,
	    			31L, 32L, 33L, 34L, 35L, 36L, 37L, 38L,
	    			41L, 42L, 43L, 44L, 45L, 46L, 47L, 48L,
	    		};
  	    for (long teethNum : permanentTeethNums) {
  	        DisplayList.addAll(TreatmentAuditLocalServiceUtil.getAuditByTeethNum(teethNum));
  	    }
    }
      
      	DisplayList = new ArrayList<>(DisplayList);
      
        DisplayList.sort(Comparator.comparing(TreatmentAudit::getEditedDate).reversed());
      
        _log.info("Audit DisplayList: " + DisplayList);
      
      renderRequest.setAttribute("mode", mode); 
      renderRequest.setAttribute("DisplayList", DisplayList);
      
      
      return "/teeth/view/auditPopup.jsp";
   }
   Log _log = LogFactoryUtil.getLog(ViewAuditRenderCommand.class);
}
