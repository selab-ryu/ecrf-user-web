package ecrf.user.teeth.constants;

import java.util.HashMap;
import java.util.Map;

public class TeethLangKey {

   private static final Map<String, String> STATUS_LABEL_KEY_MAP = new HashMap<>();

   static {
       STATUS_LABEL_KEY_MAP.put("TFA", "category.preventive");
       STATUS_LABEL_KEY_MAP.put("SC", "category.preventive");
       STATUS_LABEL_KEY_MAP.put("Sealant", "category.preventive");
       STATUS_LABEL_KEY_MAP.put("Fissurotomy", "category.preventive");

       
       STATUS_LABEL_KEY_MAP.put("Seal", "category.restoration");
       STATUS_LABEL_KEY_MAP.put("AF", "category.restoration");
       STATUS_LABEL_KEY_MAP.put("RF", "category.restoration");
       STATUS_LABEL_KEY_MAP.put("Gl", "category.restoration");
       STATUS_LABEL_KEY_MAP.put("SS", "category.restoration");
       STATUS_LABEL_KEY_MAP.put("Zr", "category.restoration");
       STATUS_LABEL_KEY_MAP.put("Comp", "category.restoration");
       STATUS_LABEL_KEY_MAP.put("GIC", "category.restoration");
       STATUS_LABEL_KEY_MAP.put("IRM", "category.restoration");
       STATUS_LABEL_KEY_MAP.put("Amal", "category.restoration");

       
       STATUS_LABEL_KEY_MAP.put("Ext", "category.surgery");
       STATUS_LABEL_KEY_MAP.put("SurgExt", "category.surgery");
       STATUS_LABEL_KEY_MAP.put("X-ray", "category.surgery");
       STATUS_LABEL_KEY_MAP.put("oral", "category.surgery");

       
       STATUS_LABEL_KEY_MAP.put("Pulpo", "category.pulp");
       STATUS_LABEL_KEY_MAP.put("Pulpec", "category.pulp");
       STATUS_LABEL_KEY_MAP.put("Apexo", "category.pulp");
       STATUS_LABEL_KEY_MAP.put("Apexi", "category.pulp");
       STATUS_LABEL_KEY_MAP.put("RCT", "category.pulp");
       STATUS_LABEL_KEY_MAP.put("PulPot", "category.pulp");
       STATUS_LABEL_KEY_MAP.put("PulpRev", "category.pulp");

       
       STATUS_LABEL_KEY_MAP.put("DOR", "category.anesthesia");
       STATUS_LABEL_KEY_MAP.put("MOR", "category.anesthesia");

       
       STATUS_LABEL_KEY_MAP.put("firstStraighten", "category.orthodontics");
       STATUS_LABEL_KEY_MAP.put("secondStraighten", "category.orthodontics");
       STATUS_LABEL_KEY_MAP.put("partialStraighten", "category.orthodontics");
       STATUS_LABEL_KEY_MAP.put("muscleFunction", "category.orthodontics");

       
       STATUS_LABEL_KEY_MAP.put("BL", "category.space_maintainer");
       STATUS_LABEL_KEY_MAP.put("LA", "category.space_maintainer");
       STATUS_LABEL_KEY_MAP.put("NHA", "category.space_maintainer");
       STATUS_LABEL_KEY_MAP.put("RSM", "category.space_maintainer");

       
       STATUS_LABEL_KEY_MAP.put("N2OSedation", "category.sedation");
       STATUS_LABEL_KEY_MAP.put("LASedation", "category.sedation");
       STATUS_LABEL_KEY_MAP.put("NHASedation", "category.sedation");
       STATUS_LABEL_KEY_MAP.put("RSMSedation", "category.sedation");

       
       STATUS_LABEL_KEY_MAP.put("Etc", "category.etc");
       STATUS_LABEL_KEY_MAP.put("Cancel", "category.etc");
   }
   
   public static String getKey(String treatment) {
	   return STATUS_LABEL_KEY_MAP.get(treatment);
   }

}
