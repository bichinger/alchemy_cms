import { reloadPreview } from "alchemy_admin/components/preview_window"
import IngredientAnchorLink from "alchemy_admin/ingredient_anchor_link"

class Action extends HTMLElement {
  constructor() {
    super()

    // map action names with Javascript functions
    this.actions = {
      // add a intermediate closeCurrentDialog - action
      // this will be gone, if all dialogs are working with a promise and
      // we don't have to implicitly close the dialog
      closeCurrentDialog: Alchemy.closeCurrentDialog,
      reloadPreview,
      updateAnchorIcon: IngredientAnchorLink.updateIcon
    }
  }

  connectedCallback() {
    const func = this.actions[this.name]

    if (func) {
      func(...this.params)
    } else {
      console.error(`Unknown Alchemy action: ${this.name}`)
    }
  }

  get name() {
    return this.getAttribute("name")
  }

  get params() {
    if (this.hasAttribute("params")) {
      return JSON.parse(this.getAttribute("params"))
    }
    return []
  }
}

customElements.define("alchemy-action", Action)
